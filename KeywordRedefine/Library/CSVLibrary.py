import csv
class CSVLibrary(object):

    def read_csv_file(self, filename):
        file = open(filename, 'r')
        csvfile = csv.reader(file)
        file.close
        return [row for row in csvfile]