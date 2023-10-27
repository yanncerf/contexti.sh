# Contexti.sh
`Pronounced like "context-ish" as it's a very unfancy and hacky way to carry out a very superficial task`
# Table de Matières

- [Installation](#installation)
  - [Linux and macOS](#linux-and-macos)
- [Usage](#usage)
- [Detailed explanation](#detailed-explanation)
- [Example Output](#example-output)
- [Shortcomings](#shortcomings)
  - [Generaly](#generaly)
  - [Varia](#varia)

*contexti.sh* is a simple script designed to count and provide percentages of references by decade, half-century, and century in academic documents. 

The idea for the script came when I had the "feeling" an article was citing rather outdated literature. I couldn't be bothered to count it and sort it by hand, yet still wanted to make sure it wasn't just an impression.

Expanded upon it could be a fun tool to gather light data on academic journals, beeing in bash it's pretty fast even on heavy and long documents, comparing between different articles from the same author or some other way I didn't think of. Be wary thought it's really not that accurate. See [the main shortcomings of this script](##Shortcomings)
## Installation
Contexti.sh is a bash script and should work on Linux and macOS systems with the required tools (pdftotext, odt2txt, docx2txt). 
### Linux and macOS
1. Make sure you have the necessary tools installed. You can typically install them with your package manager (example given for debian based distros and macOS.

   - For pdftotext: `sudo apt-get install poppler-utils` (Linux, any Debian distro)
   - For odt2txt: `sudo apt-get install odt2txt` (Linux, any Debian distro)
   - For docx2txt: `brew install docx2txt` (macOS with Homebrew)

2. Download the `contexti.sh` script.

3. Make the script executable by running: `chmod +x contexti.sh`

4. Place the script in a directory included in your system's PATH to run it from anywhere.
## Usage
Run the script with a supported document file (PDF, ODT, DOCX) as follows:

`./contexti.sh yourDocument.pdf`

The script will analyze the document, count references by decade, and provide percentages.

## Detailed explanation
The following explains line by line how the script works. Overall, the script converts supported file types to plain text, extracts references, and calculates the number and percentages of references in various time periods. It provides a summary of these statistics as output.

```bash
#!/bin/bash
```

This line specifies that the script should be executed using the Bash shell.

```bash
file_extension="${1##*.}"
```

This line extracts the file extension from the first command-line argument (`$1`) and stores it in the variable `file_extension`.

```bash
if [ "$file_extension" == "pdf" ]; then
```

This line starts a conditional statement that checks if the file extension is "pdf."

```bash
text_file="${1}.txt"
pdftotext "$1" "$text_file"
```

If the file is a PDF, these lines create a variable `text_file` with the same name as the input file but with a `.txt` extension. Then, it uses the `pdftotext` command to convert the PDF file to plain text and save it as the `text_file`.

```bash
elif [ "$file_extension" == "odt" ]; then
```

This line is part of the conditional statement and checks if the file extension is "odt" (OpenDocument Text).

```bash
text_file="${1}.txt"
odt2txt "$1" > "$text_file"
```

If the file is an ODT, these lines create the `text_file` variable with the `.txt` extension and use the `odt2txt` command to convert the ODT file to plain text.

```bash
elif [ "$file_extension" == "docx" ]; then
```

This line checks if the file extension is "docx" (Microsoft Word document).

```bash
text_file="${1}.txt"
docx2txt "$1" "$text_file"
```

If the file is a DOCX, these lines create the `text_file` variable with the `.txt` extension and use the `docx2txt` command to convert the DOCX file to plain text.

```bash
else
    echo "Unsupported file format. Please provide a PDF, ODT, or DOCX file."
    exit 1
fi
```

If the file format is not PDF, ODT, or DOCX, this part of the script prints an error message and exits the script with a status code of 1.

```bash
references=$(grep -o -P '\b(?:[A-Z][A-Za-z'"'"'`-]+)(?:,? (?:and |& )?(?:[A-Z][A-Za-z'"'"'`-]+|(?:et al.?)))*(?:,? *(?:[0-9]{4}(?:, p\.? [0-9]+)?)(?:.*)?)' "$text_file")
```

This line uses `grep` to search for references in the text file. It captures references in a specific format that includes author names, publication years, and page numbers (if available). The results are stored in the `references` variable.

```bash
years=$(echo "$references" | grep -o -E '\b(1[4-9][0-9][0-9]|20[0-9][0-9])\b')
```

This line uses a second `grep` command to extract years (YYYY) from the `references` variable. It looks for years in the range from 1400 to 2099.

```bash
reference_counts=$(echo "$years" | awk -F: '{print $1}' | awk -F. '{print $1}' | sort)
```

This line processes the `years` variable to count the references by decade. It extracts the years from references, removes any trailing characters (like page numbers), and sorts them.

```bash
total_references=$(echo "$reference_counts" | wc -l)
```

This line calculates the total number of references by counting the lines in the `reference_counts` variable.

```bash
percentages_decades=$(echo "$reference_counts" | awk '{count[int($1 / 10) * 10]++} END {for (decade in count) printf "%s: %d references (%.2f%%)\n", decade, count[decade], (count[decade]/'"$total_references"'*100) }' | sort)
```

These lines calculate the percentages of references by decades, half-centuries, and centuries. It uses `awk` to count references in each time period and calculate the percentages.

```bash
echo "Total References: $total_references"
echo "Percentage Counts by Decade:"
echo "$percentages_decades"
echo "Percentage Counts by Half-Centuries:"
echo "$percentages_half_centuries"
echo "Percentage Counts by Centuries:"
echo "$percentages_centuries"
```

These lines print the results. They display the total number of references and the percentages of references by different time periods (decades, half-centuries, and centuries).

```bash
rm "$text_file"
```

This line removes the temporary text file created during the script's execution.
## Example Output
Here's an example of what you can expect in the script output, this is for an article of mine that you can find [here](https://anthropological-notebooks.zrc-sazu.si/Notebooks/article/view/502/397)

```
Total References: 52
Percentage Counts by Decade:
1930: 2 references (3.85%)
1970: 1 references (1.92%)
1980: 3 references (5.77%)
1990: 3 references (5.77%)
2000: 19 references (36.54%)
2010: 19 references (36.54%)
2020: 5 references (9.62%)
Percentage Counts by Half-Centuries:
1950: 2 references (3.85%)
2000: 50 references (96.15%)
Percentage Counts by Centuries:
1900: 2 references (3.85%)
2000: 50 references (96.15%)
```

The total number of references in the bibliography of this article is 32. The script picked up 32 occurences of in-text citation of those authors, and the remaining 20 times I've cited an author 2 or more. Written in 2021 and focused on David Graeber's work (who sadly passed away in 2020) I think the statistics seem to be doing justice to the opech-ness of the article. Comparing with a [report](https://arodes.hes-so.ch/record/12132?ln=fr) Ossipow L., Counilh A.-L., myself ,Martenot A. & Renevier J. wrote, some interesting pattern emerges:  

```
Total References: 173
Percentage Counts by Decade:
1490: 1 references (0.58%)
1910: 1 references (0.58%)
1980: 2 references (1.16%)
1990: 10 references (5.78%)
2000: 10 references (5.78%)
2010: 59 references (34.10%)
2020: 90 references (52.02%)
Percentage Counts by Half-Centuries:
1500: 1 references (0.58%)
1900: 1 references (0.58%)
2000: 171 references (98.84%)
Percentage Counts by Centuries:
1500: 1 references (0.58%)
1900: 1 references (0.58%)
2000: 171 references (98.84%)
```

1490, 15 century?
>note 69, page 66 Les jeunes du XVe siècle étaient aussi mal aimé.es : « Certains se font mendiants à l’âge où, jeune et fort, et en pleine santé on pourrait travailler : pourquoi se fatiguer [\…]. Tous les faux estropiés et gibier de potence qui rôdent dans les foires lui font joyeuse escorte. [\…] L’autre pendant le jour traîne sur des béquilles, mais quand il se voit seul, il trotte allégrement » (**Brant 1494**, cité par Fulconis et Kikuchi 2017)

The contrast between the two output is stark, the script seems to do the job. it has it's shortcomings though.
## Shortcomings
### Generalities
Contexti.sh uses a [monster](https://www.ex-parrot.com/~pdw/Mail-RFC822-Address.html?ref=blog.codinghorror.com) of a regex (see below) to identify references, but it may also count some non-references or bibliographic references.

```bash
references=$(grep -o -P '\b(?:[A-Z][A-Za-z'"'"'`-]+)(?:,? (?:and |& )?(?:[A-Z][A-Za-z'"'"'`-]+|(?:et al.?)))*(?:,? *(?:[0-9]{4}(?:, p\.? [0-9]+)?)(?:.*)?)' "$text_file"
```

It counts in-texts references, taking into account (it's a bit hit and miss though, and there are edge cases) permutations on the APA (Author, YYYY) like:

>(AuthorA, YYYY ; AuthorB, YYYY: xx)
(Author, YYYY:xx)
(AuthorA, YYYY and AuthorB, YYYY)
(AuthorA, YYYY And AuthorB, YYYY)
(AuthorA, YYYY & AuthorB, YYYY)
(see Author, YYYY)
AuthorA said eloquently (YYYY)

So of you cite AuthorA (YYYY) two times, this will count as two occurrences.

While this command does a reasonably good job of identifying references, there may still be some edge cases or unconventional formats it may not capture accurately due to the inherent complexity and variability of reference styles in texts.You should review the output carefully and cross-verify the results if you relie on this script to actually objectify the "up-to-dateness" of a given paper.
### Varia
If you look more closely the output given as an example, and the source article, you'll see that the 1900's reference come from moments where I cite Orwell's famous Down and Out that came out in 1933.

As an example of unexpected but welcome findings, I've been able to find (yet another) typo, puzzled that I had so much 1900' references in this article :

>In-text: (Orwell, **193*3***)
>In bibliography: Orwell, G. (2013 [**193*2***]). Down and out in Paris and London. Penguin Books.

There is surely a lot more problems with the script, but I can't be bothered to tinker with it more.

The script, and parts of this readme.md was written with the help of OpenAI's ChatGPT. At first I tried something in python, but it was over-complicated for the task at hand, and Unix tools are rad so Unix it is.

Feel free to adapt and modify the script as needed for your specific use case. If you make any kind of interesting changes, or use it in ways I didn't think about, equally feel free to let me know.
