# comick.io Downloader 📚

[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](https://www.python.org/) [![GNU GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

A command-line tool to download webtoons (manhwa), comics and manga from [comick.io](https://comick.io) and package them into **PDF**, **EPUB**, or **CBZ**—with intelligent image processing, resumable downloads, scanlation group prioritization, and optional chapter/file-size splitting.

---

## 🚀 Features

- 📥 **Flexible Chapter Selection**  
  Download specific chapters, ranges (`1-5`), or lists (`1,3,5-7`).
- 🏷️ **Scanlation Group Control**  
  Prioritize your favorite scanlation group(s), or choose by highest upvotes.
- 🖼️ **Image Processing**  
  Resize, scale, recombine, and compress images for optimal reading.
- 📁 **Multiple Formats**  
  Export as PDF, fixed-layout EPUB, vertical-scroll EPUB, or CBZ.
- 🔄 **Resumable Downloads**  
  Automatically picks up where it left off if interrupted.
- ✂️ **Book Splitting**  
  Split large downloads by file size (e.g., `400MB`) or chapter count (e.g., `10ch`).
- 💾 **Keep Originals**  
  Optionally retain raw images and per-chapter files.

---

## 🛠️ Requirements

- Python 3.8+  
- [pip](https://pip.pypa.io/en/stable/)

Install dependencies:

```bash
pip install beautifulsoup4 cloudscraper lxml pillow pypdf requests
```

---

## 🧰 Installation

```bash
git clone https://github.com/zzyil/comick.io-Downloader.git
cd comick.io-Downloader
```

---

## 🚀 Usage

```bash
python3 comick_downloader.py [OPTIONS] COMIC_URL
```

Run `python3 comick_downloader.py --help` for the full option list.

---

## ⚙️ Options

| Option                        | Description                                                                                                                                                                                                                  | Default     |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `COMIC_URL`                   | URL of the comic’s main page (e.g. `https://comick.io/comic/demo-comic`)                                                                                                                                                     | _required_  |
| `--cookies STRING`            | HTTP cookie string for restricted content (e.g. `key1=val1; key2=val2`)                                                                                                                                                     | `""`        |
| `--group STRING...`           | Preferred scanlation groups (comma-separated or multiple args).                                                                                                                                                              | `[]`        |
| `--mix-by-upvote`             | When multiple `--group` entries exist, pick the version with the highest upvotes among them.                                                                                                                                 | `False`     |
| `--no-partials`               | Skip fractional chapters (e.g. 1.5).                                                                                                                                                                                          | `False`     |
| `--chapters STRING`           | Chapter filter: `all`, single (`5`), range (`1-10`), or list/ranges (`1,3,5-7`).                                                                                                                                             | `all`       |
| `--language STRING`           | Language code (e.g. `en`, `ja`).                                                                                                                                                                                              | `en`        |
| `--format {pdf,epub,cbz}`     | Output format.                                                                                                                                                                                                                | `epub`      |
| `--epub-layout {page,vertical}` | EPUB layout: `page` (fixed), `vertical` (scroll).                                                                                                                                                                             | `vertical`  |
| `--width INT`                 | Base image width (px). Defaults vary by format/layout.                                                                                                                                                                        | _auto_      |
| `--aspect-ratio STRING`       | Target W:H ratio (e.g. `4:3` or `2.5`). Not used for PDF.                                                                                                                                                                     | _auto_      |
| `--quality INT`               | JPEG quality `%` (1–100).                                                                                                                                                                                                     | `85`        |
| `--scaling INT`               | Final image scale `%` (1–100).                                                                                                                                                                                                | `100`       |
| `--split STRING`              | Split by size (`400MB`) or chapters (`10ch`).                                                                                                                                                                                | `None`      |
| `--restore-parameters`        | Reuse saved processing settings (for format-only reassembly).                                                                                                                                                                 | `False`     |
| `--keep-images`               | Retain raw downloaded images under `comics/<Title>/Chapter_<n>/`.                                                                                                                                                             | `False`     |
| `--keep-chapters`             | Save each chapter as a separate file (`.pdf`, `.epub`, or `.cbz`).                                                                                                                                                            | `False`     |
| `--no-cleanup`                | Do not delete the temporary directory (`tmp_<hid>/`) after completion.                                                                                                                                                        | `False`     |
| `-v, --verbose`               | Enable detailed logging.                                                                                                                                                                                                      | `False`     |
| `-d, --debug`                 | Enable debug-level logging (image processing details).                                                                                                                                                                        | `False`     |

---

## 🔐 Cookie Setup

If authentication is required, export your cookies:

```bash
export COOKIES='ads_provider2="…"; membership_alert=true; …'
```

Then run:

```bash
python3 comick_downloader.py --cookies "$COOKIES" \
  https://comick.io/comic/your-comic-url
```

---

## 📖 Examples

1. **Page-layout EPUB**, chapters 1–2, preferred group **Asura**, verbose:

   ```bash
   python3 comick_downloader.py \
     --cookies "$COOKIES" \
     --group Asura \
     --chapters "1-2" \
     --format epub \
     --epub-layout page \
     --verbose \
     https://comick.io/comic/demo-comic
   ```

2. **Vertical EPUB**, chapters 1–20, split every 5 chapters, verbose & debug:

   ```bash
   python3 comick_downloader.py \
     --group Asura \
     --chapters "1-20" \
     --format epub \
     --epub-layout vertical \
     --split 5ch \
     --verbose --debug \
     https://comick.io/comic/demo-comic
   ```

3. **CBZ**, chapters 1–2, one chapter per file:

   ```bash
   python3 comick_downloader.py \
     --group Asura \
     --chapters "1-2" \
     --format cbz \
     --split 1ch \
     https://comick.io/comic/demo-comic
   ```

4. **PDF**, chapters 1–2, save each chapter separately:

   ```bash
   python3 comick_downloader.py \
     --group Asura \
     --chapters "1-2" \
     --format pdf \
     --keep-chapters \
     https://comick.io/comic/demo-comic
   ```

---

## 📁 Output Structure

*   **Temporary Data**: `tmp_<hid>/`
    *   `run_params.json`: Stores the processing settings for resume functionality.
*   **Final Files**: `comics/`
    *   Named `<Title>[_Groups]_Ch_<start>-<end>.<format>` (e.g., `My_Awesome_Comic_Asura_Ch_1-5.epub`)
*   **Raw Images** (if `--keep-images` is used):
    *   `comics/<Title>/Chapter_<n>/` (e.g., `comics/My_Awesome_Comic/Chapter_1/`)

```
tmp_<hid>/                   # Temporary workspace
└── run_params.json          # Saved settings (resume/restore)
comics/
├── <Title>[_Groups]_Ch_a-b.epub/pdf/cbz   # Final build(s)
└── <Title>/Chapter_<n>/                  # Raw images (if --keep-images)
```

- Final files → `comics/`  
- Use `--no-cleanup` to inspect `tmp_<hid>/` after completion  
- Re-run with `--restore-parameters` + new `--format` to reassemble without re-downloading

---

## 🤝 Contributing

1. Fork the repo  
2. Create a feature branch (`git checkout -b feature/foo`)  
3. Commit (`git commit -m "Add foo"`)  
4. Push (`git push origin feature/foo`)  
5. Open a Pull Request  

Please follow the existing style and include tests where applicable.

---

## 📄 License

This project is licensed under the [GNU GPLv3](LICENSE).

---
