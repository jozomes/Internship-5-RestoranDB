import csv

input_file = 'C:/Users/Jozo/Downloads/RestoranNarudzba.csv'
output_file = 'C:/Users/Jozo/Downloads/RestoranNarudzba_Cleaned.csv'

with open(input_file, 'r', newline='', encoding='utf-8') as infile, open(output_file, 'w', newline='', encoding='utf-8') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)

    # Write only non-empty rows
    for row in reader:
        if any(field.strip() for field in row):
            writer.writerow(row)
