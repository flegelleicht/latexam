# latexam

# Usage

## From the Dockerfile

We have provided a `Dockerfile` to build the image needed for running everything (This will build a 2.8GB image with ruby, texlive and pdftk installed).

	latexam$ docker build -t latexam .
		
### Create only an exam sheet
	
	latexam$ docker run -it --rm -v "$PWD":/data -w /data latexam ruby bin/create-exam.rb <path to catalog file> <path to output file>

Returns the id of the exam, needed for generating the solution:

	q0a5a6a3a2a0a1a4tq0a2a4a5a0a3a1
	
### Create the solution for an existing exam
	
	latexam$ docker run -it --rm -v "$PWD":/data -w /data latexam ruby bin/create-specific-exam.rb <path to catalog file> <path to output file> <exam key>
	
### Generate pdfs for exam or solution

	latexam$ docker run -it --rm -v "$PWD":/data -w /data latexam xelatex <path to tex file>
	
We might have to run this more than once. Or... we use `latexmk` to make this a single step:

	latexam$ docker run -it --rm -v "$PWD":/data -w /data latexam latexmk -xelatex <path to tex file>
	
### Build exam, solution and pdfs in one step
	
	latexam$ docker run -it --rm -v "$PWD":/data -w /data latexam ruby bin/create-sheet-and-solution-for.rb [<exam suffix>]

### Compare a given exam pdf with the expected solution

	latexam$ docker run -it --rm -v "$PWD":/data -w /data latexam ruby bin/check-exam.rb <path to expected solution> <path to given>


## Via existing docker images

Latexam is a pure ruby script with no dependencies. This way it is easy to run via the `ruby:alpine` docker container (This will install a 45MB image for ruby):

	latexam $ docker run -it --rm --name create-exam -v "$PWD":/docker -w /docker ruby:alpine ruby bin/create-exam.rb data/catalog/example.txt data/exam.tex
	tq0a5a6a3a2a0a1a4tq0a2a4a5a0a3a1 # The id of the exam, needed for generating the solution in the next step
	
Plug the id into the next step. The script will print a representation of the questionnaire to the console.
	
	latexam $ docker run -it --rm --name create-solution -v "$PWD":/usr/src/myapp -w /usr/src/myapp ruby:alpine ruby bin/create-specific-exam.rb data/catalog/example.txt data/solution.tex tq0a5a6a3a2a0a1a4tq0a2a4a5a0a3a1
	Thema Nummer 1
	  Welche der folgenden Antworten sind richtig?
	    Antwort 6
	    Antwort 7
	    Antwort 4
	    Antwort 3
	    Antwort 1
	    Antwort 2
	    Antwort 5
	Thema Nummer 2
	  Welche der folgenden Antworten sind richtig?
	    Antwort 3
	    Antwort 5
	    Antwort 6
	    Antwort 1
	    Antwort 4
	    Antwort 2
		
After generating the exam and solution we need to compile them via xelatex to get the pdf. We are going to this via docker again (This will install a 4.4GB image for LaTeX, but still better than installing it yourself). First, change into the `data` directory so that `xelatex` will find the imagess, fonts nstuff referenced in the `.tex` file
	
	latexam $ cd data
	data $ docker run -it --rm -v "$PWD":/docker -w /docker aergus/latex xelatex exam.tex

We will get a lot of output printed to the console. If one of the last messages is...

	LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.

... we will have to simply run the same command again. Explanation for this particular project: xelatex counts the pages in a first pass (among many other things, of course) and needs a second pass to insert them at the correct places. So, we'll run the exact command again:
		
	data $ docker run -it --rm -v "$PWD":/docker -w /docker aergus/latex xelatex exam.tex