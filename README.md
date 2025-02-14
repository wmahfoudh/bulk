# bulk.sh - Bulk File Processing Utility

A bash script for processing files in bulk with custom commands, output directories, and file extensions. Transform, convert, or analyze files en masse with a single command!

## Features

- 🔍 **Pattern-based file selection:** using `(scope=GLOB_PATTERN)`
- 📂 **Custom output directories:** via `(out=DIRECTORY)`
- 🎚️ **Output extension control:** with `(ext=EXTENSION)`
- 🛠️ **Command templating:** supporting pipes and redirections
- ✅ **Space-safe filename handling**
- 🚀 **Parallel-ready:** when combined with utilities like `xargs` or `parallel`

## Usage

```bash
./bulk.sh "COMMAND (scope=GLOB) (out=DIR) (ext=EXT)"
```

### Key Parameters

| Parameter      | Description                                      | Default           |
|----------------|--------------------------------------------------|-------------------|
| (scope=GLOB)   | File selection pattern (required)                | -                 |
| (out=DIR)      | Output directory                                 | Current directory |
| (ext=EXT)      | Output file extension                            | txt               |

### Basic Examples

#### PDF to Text Conversion

```bash
./bulk.sh "pdftotext (scope=*.pdf) (out=converted_text_files)/(ext=txt)"
```

#### Use it with Fabric 😉

```bash
./bulk.sh "cat (scope=*.txt) | fabric -p clean > (out=clean)/(ext=md)"
```

#### Image Resizing

```bash
./bulk.sh "convert (scope=*.jpg) -resize 50% (out=resized)/(ext=jpg)"
```

#### Other Use Case Ideas

**Multi-stage Document Processing**  
Converts PDFs to text while adding line numbers.

```bash
./bulk.sh "pdftotext (scope=*.pdf) | nl > (out=numbered)/(ext=txt)"
```

**Real-time Language Translation**  
Batch translates text files to Spanish using translate-shell.

```bash
./bulk.sh "trans -b :es (scope=*.txt) > (out=spanish)/(ext=txt)"
```

**Audio Conversion & Metadata**  
Converts WAV to MP3 while setting artist metadata.

```bash
./bulk.sh "ffmpeg -i (scope=*.wav) -metadata artist=Me (out=mp3s)/(ext=mp3)"
```

**Codebase Sanitization**  
Redacts sensitive information from configuration files.

```bash
./bulk.sh "sed 's/API_KEY=.*/API_KEY=REDACTED/' (scope=.env*) > (out=safe)/(ext=env)"
```

**Dataset Augmentation**  
Adds timestamps to JSON documents using jq.

```bash
./bulk.sh "jq '.timestamp = now' (scope=*.json) > (out=updated)/(ext=json)"
```

## How It Works

1. **Parameter Parsing**  
   The script expects a single string argument containing three parameters embedded in parentheses:
   - **Scope:** `(scope=pattern)` – a glob pattern for selecting files (e.g., *.pdf or *.txt).
   - **Output Directory:** `(out=folder)` – the folder where processed files will be saved (defaults to the current directory if omitted).
   - **Output Extension:** `(ext=extension)` – the file extension for output files (defaults to txt if omitted).

2. **Command Template Formation**  
   The script forms a command template by:
   - Replacing the `(scope=...)` token with a placeholder `__FILE__` which is later substituted with each file name.
   - Replacing the combination `(out=folder)/(ext=extension)` with another placeholder `__OUTFILE__`, which is used to generate the destination file using the input file's basename.

3. **Processing Files**  
   For each file that matches the scope pattern:
   - The script constructs the output file path.
   - It substitutes the placeholders in the command template with properly quoted file names (handling spaces safely).
   - The resulting command is echoed and executed using `eval`.

## Requirements

- **Bash 4.0+ or compatible** (tested on ZSH)
- Basic UNIX utilities: `sed`, `mkdir`, `basename`
- Additional commands as used in processing (e.g., `pdftotext`, `ffmpeg`, `jq`, etc.)

## Limitations

- **Strict Parameter Syntax:**  
  The script requires exact parentheses formatting (no spaces after `=`).

- **Usage of eval:**  
  Ensure that commands come from trusted sources to avoid security risks.

- **Non-halting Errors:**  
  Errors in processing individual files do not stop the execution of the entire script.

## Contribution

Found a clever use case? Submit a PR to add it to our examples! Please ensure:

- Commands are cross-platform friendly.
- Use cases demonstrate novel combinations.
- Include required dependencies in the descriptions.

## Pro Tip: Parallel Processing

Combine with parallel for ultra-fast processing:

```bash
parallel ./bulk.sh "ml-process (scope={}) (out=processed)" ::: *.data
```
