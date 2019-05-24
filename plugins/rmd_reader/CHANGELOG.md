# Changelog for RMD Reader

## October 28, 2017

*   Fixed typo from `#-*- conding: utf-8 -*-` to `#-*- coding: utf-8 -*-` in header of `rmd_reader.py`

## October 7, 2017

*   Modify command-line arguments passed to pandoc in `pandoc_reader.py` when generating HTML output
    
    *   Arguments changed from
        
        ```python
        pandoc_cmd = ["pandoc", "--from=markdown" + extensions, "--to=html5"]
        ```
        to
        
        ```python
        pandoc_cmd = [
            "pandoc", "+RTS", "-K512m", "-RTS", "--from=markdown" + extensions,
            "--to=html5"
        ]
        ```

## September 14, 2017

*   Fixed bug that led to images rendered by knitr going into the wrong directory
    
    *   Fix accomplished by using the `SITEURL` variable from the `pelicanconf.py` file and passing it to `knit_hooks`:
        
        ```
        knit_hooks$set(plot=function(x, options) hook_plot(paste0("{SITEURL}/", x), options))
                    '''.format(unnamed_chunk_label=chunk_label, SITEURL=site_url))
        ```

## September 1, 2017

*   The plugin was updated to use Pandoc to parse Markdown files

    *   Added the file `pandoc_reader.py` from the Pelican plugin [Pandoc Reader]

    *   Swapped out the the Python-based `MarkdownReader` for `PandocReader` in `rmd_reader.py`

[Pandoc Reader]: https://github.com/liob/pandoc_reader/tree/9ef0197eed5d141bf0f3b9a8468cd37ad3e5fbd7
