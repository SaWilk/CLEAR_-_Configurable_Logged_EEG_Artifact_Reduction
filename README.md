# CLEAR — Configurable, Logged EEG Artifact Reduction

CLEAR is a configurable MATLAB pipeline for EEG preprocessing. It provides a common workflow for preparing continuous recordings, removing artifacts, and creating epochs for analysis. The default settings provide a starting point and can be adapted to the recording setup, experimental design, and research question.
The initial defaults were agreed upon in January 2026 to be used as a shared preprocessing pipeline in DFG Research Unit 5389.

## Supported inputs

CLEAR imports BrainVision recordings directly. For recordings from other systems, provide a continuous EEGLAB dataset with the required channel information and event markers for Step 03.

## Before you start

Install MATLAB with **Signal Processing Toolbox** and **Statistics and Machine Learning Toolbox**. Install [EEGLAB](https://eeglab.org/) with BrainVision import support (`pop_loadbv`). The table shows which additional packages the supplied settings use and when you need an alternative.

| Operation | Supplied setting | Software |
| --- | --- | --- |
| Bad-channel detection | `clean_rawdata` | clean_rawdata EEGLAB plugin |
| Line-noise removal | `zapline` | Zapline-plus. Install CleanLine if you select `pop_cleanline` or rely on the configured CleanLine fallback. |
| Rejection of ICA training segments and final epochs | `erplab` | ERPLAB. For the `faster_ptp` alternative, install FASTER when its FASTER criterion is enabled. |
| ICA decomposition | `runica` | Included with EEGLAB. The `amica` option requires AMICA and an executable that runs on the processing machine. |
| Component classification | ICLabel | ICLabel EEGLAB plugin |
| Parallel processing across participants | Configurable | Parallel Computing Toolbox. A single-participant test can run serially. |

<br>

## Configure your first run

Open the repository's top-level folder in MATLAB. For a new study, edit two files.

1. In **`eeg_pipeline_local_paths.m`**, replace the `CHANGE_ME` entries for your machine. Set the data folders shown below and the EEGLAB, ERPLAB, and FASTER paths as applicable under `local.toolboxes`. The config selects a machine profile automatically. Use `cfg.paths.profile_override` if you need to select `pc`, `server_windows`, or `hpc_hummel` explicitly.
2. Open **`eeg_pipeline_config.m`**. You can edit it directly or save a study-specific copy. If you rename the file, change the function name on its first `function` line to match. Make all `cfg` edits inside that function.

| Folder | What goes there |
| --- | --- |
| `source_eeg_root` | Original BrainVision files. Step 01 searches this directory directly for `.vhdr` headers. Keep each header with its matching `.vmrk` and signal file (`.eeg` or `.dat`). |
| `source_beh_root` | Optional source folder for supported behavioral logs. Leave empty if unused. |
| `bids_root` | Destination for Step 01, or the existing BIDS dataset containing your `sub-*` folders. |
| `derivatives_root` | Preprocessed datasets, QC tables, and logs. Choose a fresh destination for the first test. |

<br>

**Identify the recording.** Set the pipeline name, master-log prefix, and BIDS dataset, task, and session labels. Set `cfg.pipeline.step_prefix = "eeg"` for the supplied functions. Match `cfg.constants.valid_sub_id_regex` to the participant IDs and `cfg.prep_01.raw_eeg_regex` to the header filenames. The latter captures the numeric participant ID first and an optional run label second. The template assumes `B_003.vhdr` and `B_003_001.vhdr`. For a new naming scheme, test an actual filename before running a batch.

**Choose the starting point.** With original recordings, enable Step 01 and use a fresh BIDS destination. With an existing BIDS dataset, disable `cfg.steps.prep_01_bids_formatting.run`. Enable Step 02 if markers need recoding. If the BIDS markers already have the analysis codes, you can start at Step 03 with fresh derivatives. Step 03 prefers an existing trigger-fixed dataset over the BIDS header.

**Check the overwrite settings before the first run.** The template sets `cfg.io.overwrite_mode = "skip"` globally, but all six entries under `cfg.steps` explicitly specify `"delete"`. These per-step values take precedence. Choose `"skip"` to reuse existing step outputs, `"delete"` to replace them, or `"if_older_than"` with an `overwrite_if_older_than` date for a selective rebuild. An empty per-step mode inherits the global setting. With `cfg.steps.enable_downstream_rerun = true`, rebuilding an earlier step can also schedule later steps. For an isolated test, turn propagation off and enable only the intended steps.

## What the six steps do

| Step | Input and output | Decisions to make |
| --- | --- | --- |
| **01 · BIDS formatting** | Copies BrainVision files into the BIDS participant/session layout and updates the internal file references. | Set the filename pattern and BIDS labels. Enable `do_beh` only if using the supported CF behavior-log format. |
| **02 · Triggerfix** | Imports the BIDS recording, applies task-specific trigger mappings, and writes `*_triggersfixed.set`. | Define raw markers, conditions, and any phase boundaries in `cfg.paradigms.myParadigm.triggerfix`. Check the corrected event codes and counts. |
| **03 · Until ICA** | Filters and prepares continuous EEG. Writes `*_preica.set` for analysis and `*_forica.set` for ICA training. | Match EEG, EOG, ECG, and other auxiliary channel labels to the recording. Review sampling rate, filters, reference, line-noise removal, bad-channel detection/interpolation, and optional task or break cropping. |
| **04 · ICA** | Fits ICA to `*_forica.set`, transfers the weights to the matching continuous `*_preica.set`, and writes `*_ica_applied.set`. | Choose `cfg.prep_04.ica_method`, the channel set, and rank handling. For AMICA, inspect convergence in the QC output. |
| **05 · After ICA** | ICLabel classifies components. The pipeline removes components meeting the enabled class thresholds, checks the resulting signal, and writes `*_until_epoching.set`. | Select artifact classes and probability thresholds. Inspect component decisions, scalp maps if enabled, and signal QC. A hard signal-QC failure can prevent the cleaned dataset from being saved. |
| **06 · Epoching** | Cuts cleaned continuous data into epochs and rejects residual artifacts. Final datasets use `*_epoched_final.set` or condition-specific or split filenames. | Choose event-locked or fixed-length epochs, a rejection method, optional baseline correction, and minimum retained trial counts. |

<br>

**Triggerfix and multiple runs.** For tasks without phases, set `use_gating_from_start_markers = false` and `blocking.count_scope = "global"`. For phase-specific rules, define `gates.start_markers`, enable gating, and set the count scope to `"phase"`. The optional raw-order check expects RTGMN/CF behavioral logs. Set `cfg.paradigms.myParadigm.triggerfix.run_raw_order_qc = false` for other formats. If several trigger-fixed files share the same Step 02 output directory, Step 03 selects the most recently modified file. For separate runs, use separate output locations and verify the selected input in the participant log.

**Analysis data and ICA training data.** The Step 03 template resamples to 250 Hz, uses an average reference and 0.1–40 Hz analysis filters, and sets a 1 Hz high-pass for the ICA training copy. Rejection of short training segments determines which data contribute to the ICA fit. Final trial retention is determined separately in Step 06.

### Optional cropping in Step 03

Both options are off by default. They act on the continuous recording before bad-channel detection and preparation of the ICA training copy.

- **Task cropping** keeps the interval between task start and task end. Set `cfg.prep_03.crop_to_task_markers = true` and specify `crop_start_marker` and `crop_end_marker`. For repeated markers, select the intended occurrence (`"first"` or `"last"`). With `substitute_crop_markers = true`, a missing marker falls back to the corresponding recording boundary.
- **Break cropping** removes pauses *within* the retained recording. Set `cfg.prep_03.break_crop_method = "markers"` for paired `break_start_marker` and `break_end_marker` events. Choose `"trial_count"` when pauses must be inferred: specify trial-onset and trial-end markers, expected blocks, and trials per block. Only gaps at expected block boundaries are eligible, and each must meet `break_min_gap_sec` to be removed.

Set `break_padding_sec` to preserve enough data after the preceding trial and before the next one for your planned epochs. On the first run, check `<derivatives_root>/qc/03_break_cropping/` to see whether breaks were removed. With the default `break_on_validation_fail = "skip"`, failed validation skips break removal and processing continues.

**Epoching example.** For an event-related analysis, enter the marker strings exactly as they appear in the Step 03 input. In this example, `S 50` and `S 51` are two outcome conditions. Epoch limits use seconds and the baseline interval uses milliseconds.

```matlab
cfg.prep_06.epoching_mode = "event_locked";
cfg.prep_06.events_phase = {'S 50', 'S 51'};
cfg.prep_06.epoch_start_s = -0.2;
cfg.prep_06.epoch_end_s = 0.8;
cfg.prep_06.do_baseline_correction = true;
cfg.prep_06.base_start_ms = -200;
cfg.prep_06.base_end_ms = 0;
cfg.prep_06.min_trials_per_condition_codes = {
    'NoCP', {'S 50'};
    'CP',   {'S 51'}
};
```

For resting-state data, choose `epoching_mode = "baseline"` and set `regepoch_length_sec` and `regepoch_step_sec`. To separate marked conditions such as eyes open and eyes closed, enable `baseline_has_conditions` and fill `baseline_condition_definitions`. Baseline correction has its own switch in both modes.

## Test locally, then run the cohort

Set `cfg.parallel.enable = false` for the first test. From the repository root, run one participant whose filename and markers you know. Pass the config function name without `.m` and the participant ID as text to preserve leading zeros.

```matlab
run_eeg_pipeline('eeg_pipeline_config', '003')
```

Check the input selected in the participant log, the channels and segments retained for ICA, the removed components, and the final epoch counts by condition. Once these match your design, run a list of participants or let the config select them.

```matlab
run_eeg_pipeline('eeg_pipeline_config', {'003','004','005'})
run_eeg_pipeline('eeg_pipeline_config')
```

An explicit list in the call overrides the config's participant list and minimum-ID filter. With no IDs in the call, the runner uses the configured selection or discovers participants.

**Running on Hummel.** Use the Hamburg guides below for the interactive MATLAB workflow and file transfer. Set the profile's paths to locations visible on the compute node. Use `runica` for the documented Hummel workflow.

## Results, troubleshooting, and support

| Where to look | What to check |
| --- | --- |
| `<derivatives_root>/logs/` | The master log records resolved paths, profile, planned work, and participant status. The master log also gives the path to the participant-status table, which lists failures and their log files. The participant log identifies the input file, completed steps, and the first error. |
| `<derivatives_root>/qc/` | Step 03 reports bad channels and ICA training retention. Step 05 reports ICLabel decisions and signal checks. Step 06 reports rejected and retained epochs. Check the overall rejection rate and the counts in each analysis condition. |
| Step 05 and Step 06 output folders | Use the Step 05 dataset for cleaned continuous EEG and Step 06 for epoched analyses. Check the ICA-method branch when `branch_by_ica_method` is enabled. Keep paired `.set` and `.fdt` files together. |

<br>

After a batch, open `logs/<timestamp>_pipeline_subject_status.csv` for failed participants and their log paths. Then open `qc/<timestamp>_ica_qc_overview.csv` and check `decision` and `recommended_action` for each flagged ICA run.

If no header matches, check the active profile, source folder, ID pattern, and task/session labels. If a config change produces “No subjects required work,” check the step's overwrite setting. For unexpected trial loss, compare the event counts before epoching with the Step 06 rejection reasons and minimum-trial settings. 

### Tutorials

| When you need more detail | Guide |
| --- | --- |
| Set up a new task or define phase-specific trigger mappings | [Configuration walkthrough](tutorials/HowTo_Config.txt). Check the current config for available methods and defaults. |
| Enable QC exports or interpret the Step 03, 05, and 06 summary tables | [QC summary functions](tutorials/HowTo_summary_functions.txt) |
| Interpret an ICA warning or choose which step to rerun | [ICA quality control](tutorials/README_ICA_QUALITY_CONTROL.md) |
| See the preprocessing sequence and the separate ICA training copy | [Common EEG preprocessing handout](tutorials/2026-08-10_Common_EEG_Preprocssing_Handout_v1.0.docx) |
| Run on Hummel or transfer results to Hamburg network drives | [Hummel walkthrough](tutorials/how_to_run_on_hummel_hpc.txt) and [file transfer](tutorials/transfer_files_hummel-Z.txt) |

<br>

### Support

For a reproducible error or a configuration issue that prevents your analysis, contact **Saskia Wilken** at [saskia.wilken@uni-hamburg.de](mailto:saskia.wilken@uni-hamburg.de). Include the command you ran, the relevant config settings, the steps needed to reproduce the issue, and the exact error message or a screenshot. A short excerpt from the participant log helps locate the failure.

## License and third-party software

Copyright (C) 2025–2026 Saskia Wilken and contributors. CLEAR is licensed under the GNU General Public License v3.0 or later (GPL-3.0-or-later). See [LICENSE](LICENSE) for details and check individual files for explicit exceptions.

Install EEGLAB, ERPLAB, ICLabel, and other selected third-party packages separately. They retain their respective licenses and terms of use. MATLAB and MathWorks toolboxes are distributed separately under the applicable MathWorks license terms.
