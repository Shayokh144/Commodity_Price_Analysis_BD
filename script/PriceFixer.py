#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 19 13:05:51 2023

@author: taher
"""
import os
import csv
import re

def get_actual_price(raw_price):
    priceStr = re.findall(r'\d+', raw_price)
    priceText = str(sum(map(int, priceStr)))
    return priceText

def find_csv_files(directory):
    csv_files = []

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.csv'):
                csv_files.append(os.path.join(root, file))

    return csv_files


def update_price(fileUrls):
    for csv_file in fileUrls:
        with open(csv_file, 'r') as file:
            reader = csv.reader(file)
            data = list(reader)
            for row in data:
                if "+" in row[4]:
                    print(row[5])
                    row[5] = get_actual_price(row[4])
                    print(row[5])
            write_data_in_csv(csv_file, data)

def write_data_in_csv(filePath, dataList):
    with open(filePath, 'w', encoding='UTF8', newline='') as f:
        writer = csv.writer(f)
        writer.writerows(dataList)
        f.close()
    return


def main():
    #"./data/price_data/"
    current_directory = os.path.dirname(__file__)
    parent_directory = os.path.dirname(current_directory)
    data_directory = parent_directory + "/data/price_data/"
    files = find_csv_files(data_directory)
    #print(files)
    update_price(files)


if __name__ == "__main__":
    main()
