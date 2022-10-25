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
from datetime import date
import os

def get_product_data(productPageUrl):
    productData = []
    try:
        hdr = {'User-Agent': 'Mozilla/5.0'}
        req = Request(productPageUrl, headers=hdr)
        response = urlopen(req)
        statusCode = response.getcode()
        nameText = ""
        weightText = ""
        priceText = ""
        discountPriceText = ""
        weightValue = ""
        weightUnit = ""
        print ('status code = ',statusCode)
        if statusCode == 200:
            soupObject = BeautifulSoup(response, "lxml")
            productDivs = soupObject.find_all("div",{"class":"product"})
            print('number of div found = ',len(productDivs))
            
            for div in productDivs:
                try:
                    nameText = div.find("div",{"class":"name"}).get_text()
                except:
                    nameText = ""
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
                try:
                    priceText = div.find("div",{"class":"price"}).get_text()
                    priceText = re.sub('[^.0-9]','', priceText)
                except:
                    priceText = ""
                try:
                    discountPriceText = div.find("div",{"class":"discountedPriceSection"}).get_text()
                    discountPriceText = re.sub('[^.0-9]','', discountPriceText)
                except:
                    discountPriceText = ""
                data = [nameText, weightText, weightValue, weightUnit, priceText, discountPriceText]
                productData.append(data)
                nameText = ""
                weightText = ""
                priceText = ""
                discountPriceText = ""
                weightValue = ""
                weightUnit = ""
    except:
        print("product data not found for given url:", productPageUrl)
    return productData



def write_data_in_csv(path, header, dataList):
    with open(path, 'w', encoding='UTF8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(dataList)
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

def get_current_date():
    #dd-mm-yyyy
    today = date.today()
    return today.strftime("%d-%m-%Y")

#print(get_product_data(url))
#write_data_in_csv("../data/URLList.csv", headerData, urlData)
#read_data_from_csv("../data/URLList.csv")
print(get_current_date())
urls = read_data_from_csv("../data/URLList.csv")
parentDir = "../data/price_data/"
for url in urls:
    dirName = url[0].replace(" ", "_")
    path = os.path.join(parentDir, dirName)
    os.mkdir(path)

