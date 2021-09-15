# rslib.rb

This is a minimal Sinatra app to conveniently search/browse record sheet
PDFs. It will only serve the specific page, making it friendly for mobile
or other resource-constrained systems that will choke on 100-page
PDFs.

## Dependencies

Install gems with bundler.

rsindex.rb relies on pdftk being installed

## Usage

First, index the record sheet library with rsindex.rb:

```
rsindex.rb *.pdf > index.csv
```

Run the sinatra app. Specify the base directory containing PDFs (and the index)

```
bundle exec ruby app.rb /path/to/recordsheets/
