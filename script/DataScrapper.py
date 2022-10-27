#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 25 13:05:51 2022

@author: taher
"""
import re
from urllib.request import urlopen, Request
from bs4 import BeautifulSoup
import csv
from datetime import datetime
import os

def get_product_data(productPageUrl):
    productData = []
    date, time = (get_current_date_time())
    LOG_DATA = []
    try:
        hdr = {'User-Agent': 'Mozilla/5.0'}
        req = Request(productPageUrl, headers=hdr)
        response = urlopen(req)
        statusCode = response.getcode()
        nameText = ""
        weightText = ""
        priceRawValue = ""
        priceText = ""
        discountPriceRawValue = ""
        discountPriceText = ""
        weightValue = ""
        weightUnit = ""
        #LOG_DATA.append("status code: "+ str(statusCode) + " for url: "+productPageUrl)
        if statusCode == 200:
            soupObject = BeautifulSoup(response, "lxml")
            productDivs = soupObject.find_all("div",{"class":"product"})
            for div in productDivs:
                missingDataCount = 0
                try:
                    nameText = div.find("div",{"class":"name"}).get_text()
                except:
                    nameText = ""
                    missingDataCount += 1
                try:
                    weightText = div.find("div",{"class":"subText"}).get_text()
                    weightList = weightText.split()
                    if len(weightList) == 2:
                        weightValue = weightList[0]
                        weightUnit = weightList[1]
                    if len(weightList) == 1:
                        weightValue = "1"
                        weightUnit = weightText
                except:
                    weightText = ""
                    weightValue = ""
                    weightUnit = ""
                    missingDataCount += 1
                try:
                    priceRawValue = div.find("div",{"class":"price"}).get_text()
                    priceText = re.sub('[^.0-9]','', priceRawValue)
                except:
                    missingDataCount += 1
                    priceRawValue = ""
                    priceText = ""
                try:
                    discountPriceRawValue = div.find("div",{"class":"discountedPrice"}).get_text()
                    discountPriceText = re.sub('[^.0-9]','', discountPriceRawValue)
                except:
                    discountPriceRawValue = ""
                    discountPriceText = ""
                data = [
                    nameText, 
                    weightText, 
                    weightValue, 
                    weightUnit, 
                    priceRawValue, 
                    priceText, 
                    discountPriceRawValue, 
                    discountPriceText,
                    date,
                    time
                    ]
                dataStr = ' '.join(data)
                dataStr = dataStr.lower()
                if "loading more" not in dataStr and missingDataCount < 2:
                    productData.append(data)
                #LOG_DATA.append(' '.join(data))
                nameText = ""
                weightText = ""
                priceText = ""
                priceRawValue = ""
                discountPriceText = ""
                discountPriceRawValue = ""
                weightValue = ""
                weightUnit = ""
    except Exception as e:
        LOG_DATA.append("EXception occured: "+e)
        LOG_DATA.append("Data not found for url = " + productPageUrl)
    
    write_log(LOG_DATA)
    return productData



def write_data_in_csv(filePath, header, dataList):
    with open(filePath, 'w', encoding='UTF8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(dataList)
        f.close()
    return

def add_new_data_in_csv(filePath, dataList):
    with open(filePath, 'a', encoding='UTF8', newline='') as f:
        writer = csv.writer(f)
        writer.writerows(dataList)
        f.close()
    return

def read_data_from_csv(filePath, skipHeader = True):
    data = []
    with open(filePath, 'r') as f:
        csv_reader = csv.reader(f)
        if skipHeader == True:
            next(csv_reader)
        for line in csv_reader:
            #print(line)
            data.append(line)
    return data

def get_current_date_time():
    #dd-mm-yyyy HH:MM:SS
    today = datetime.now()
    dateTime = today.strftime("%d-%m-%Y %H:%M:%S").split(" ")
    return (dateTime[0], dateTime[1])

def create_new_csv_file(parentDir, newDirName, csvHeaders = []):
    newDirName = newDirName.replace(" ", "_")
    newFileName = newDirName+".csv"
    dirPath = os.path.join(parentDir, newDirName)
    filePath = os.path.join(dirPath, newFileName)
    if os.path.isdir(dirPath) == False:
        os.mkdir(dirPath)
        write_data_in_csv(filePath, csvHeaders, [])
    else:
        if os.path.exists(filePath) == False:
            write_data_in_csv(filePath, csvHeaders, [])
    return filePath

def write_log(logTextList = []):
    date, time = (get_current_date_time())
    logFilePath = "./data/log.txt"
    with open(logFilePath, 'a') as f:
        for logText in logTextList:
            logText = date + "  " + time + "    " + logText + "\n"
            f.write(logText)
        f.close()
    return

def main():
    parentDir = "./data/price_data/"
    urlListFilePath = "./data/URLList.csv"
    headers = [
        "product_name", 
        "weight_raw", 
        "weight_value", 
        "weight_unit", 
        "price_raw", 
        "price", 
        "discount_price_raw", 
        "discount_price",
        "date",
        "time"
        ]
    urls = read_data_from_csv(urlListFilePath)
    for url in urls:
        filePath = create_new_csv_file(parentDir, url[0], headers)
        productData = get_product_data(url[2])
        add_new_data_in_csv(filePath, productData)


if __name__ == "__main__":
    print("PYTHON CODE STARTED")
    write_log(["script starts for testing github action"])
    main()
    write_log(["script ends for testing github action"])