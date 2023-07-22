# md_parser.sh

This bash script parses the headers of a markdown file and creates a new file for every header found. It also dumps all content under that header into the file. This script was written for use with [Obsidian](https://obsidian.md/). Using this, I propagate my MOC file containing brief information about academic journals into a web view in Obsidian's graph view. 

the script will parse level 1 headers and will only recognize headers with asterisks on either side of the name, like so:


```
# *Geographical Analysis* 

~content~

# *American Education Research Journal*

~content~

etc.

```

This script was created using Chat GPT. I have copied and pasted the entire log of my interaction with Chat GPT into a text file. 
