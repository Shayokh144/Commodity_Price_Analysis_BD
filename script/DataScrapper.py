#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 25 13:05:51 2022

@author: taher
"""
from time import sleep
import re
from urllib.request import urlopen, Request
from bs4 import BeautifulSoup
import csv
from datetime import datetime
import os

def _fetch_html(productPageUrl):
    hdr = {'User-Agent': 'Mozilla/5.0'}
    req = Request(productPageUrl, headers=hdr)
    response = urlopen(req)
    statusCode = response.getcode()
    html = response.read().decode("utf-8", errors="ignore")
    return statusCode, html


def _fetch_rendered_html(productPageUrl, log_data):
    try:
        from playwright.sync_api import sync_playwright
    except Exception as e:
        log_data.append("Playwright not installed: " + str(e))
        return None
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True, args=["--no-sandbox"])
            page = browser.new_page()
            page.set_extra_http_headers({
                "User-Agent": "Mozilla/5.0",
                "Accept-Language": "en-US,en;q=0.9"
            })
            page.goto(productPageUrl, wait_until="networkidle", timeout=60000)
            # Give the app time to render products after initial load.
            try:
                page.wait_for_selector("div.productV2Catalog, div.product", timeout=10000)
            except Exception:
                log_data.append("No product selector visible after 10s")
            # Some categories lazy-load; trigger scroll a few times.
            for _ in range(3):
                page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
                page.wait_for_timeout(2000)
            page.evaluate("window.scrollTo(0, 0)")
            page.wait_for_timeout(2000)
            html = page.content()
            browser.close()
            return html
    except Exception as e:
        log_data.append("Playwright render failed: " + str(e))
        return None


def _extract_products_from_html(html, date, time):
    productData = []
    hasRealProduct = False
    soupObject = BeautifulSoup(html, "lxml")
    productDivs = soupObject.find_all("div", {"class": "product"})
    if len(productDivs) == 0:
        productDivs = soupObject.find_all("div", {"class": "productV2Catalog"})
    loadingOnly = False
    for div in productDivs:
        missingDataCount = 0
        nameText = ""
        weightText = ""
        priceRawValue = ""
        priceText = ""
        discountPriceRawValue = ""
        discountPriceText = ""
        weightValue = ""
        weightUnit = ""
        try:
            nameText = div.find("div", {"class": "name"}).get_text()
        except:
            nameText = ""
            missingDataCount += 1
        if nameText == "":
            try:
                nameText = div.find("div", {"class": "pvName"}).get_text()
            except:
                nameText = ""
                missingDataCount += 1
        try:
            weightText = div.find("div", {"class": "subText"}).get_text()
            weightMatch = re.search(r'(\d+(?:\.\d+)?)\s*([a-zA-Z]+)', weightText)
            if weightMatch:
                weightValue = weightMatch.group(1)
                weightUnit = weightMatch.group(2)
                weightText = weightValue + " " + weightUnit
            else:
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
            priceRawValue = div.find("div", {"class": "price"}).get_text()
            priceText = re.sub('[^0-9]', '', priceRawValue)
        except:
            missingDataCount += 1
            priceRawValue = ""
            priceText = ""
        try:
            discountPriceRawValue = div.find("div", {"class": "discountedPrice"}).get_text()
            nums = re.findall(r'\d+', discountPriceRawValue.replace(',', ''))
            discountPriceText = nums[0] if len(nums) > 0 else ""
        except:
            discountPriceRawValue = ""
            discountPriceText = ""
        if discountPriceRawValue == "":
            try:
                discountPriceRawValue = div.find("div", {"class": "productV2discountedPrice"}).get_text()
                nums = re.findall(r'\d+', discountPriceRawValue.replace(',', ''))
                discountPriceText = nums[0] if len(nums) > 0 else ""
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
        dataStr = ' '.join(data).lower()
        if "loading more" not in dataStr and missingDataCount < 2:
            productData.append(data)
            hasRealProduct = True
        if "loading more" in dataStr and missingDataCount >= 1:
            loadingOnly = True
    return productData, len(productDivs), hasRealProduct, loadingOnly


def _slug_from_url(url):
    slug = re.sub(r'^https?://', '', url)
    slug = re.sub(r'[^a-zA-Z0-9]+', '_', slug)
    return slug.strip('_')


def _save_debug_html(html, filename):
    debugDir = "./data/debug"
    if os.path.isdir(debugDir) == False:
        os.makedirs(debugDir, exist_ok=True)
    filePath = os.path.join(debugDir, filename)
    with open(filePath, 'w', encoding='UTF8') as f:
        f.write(html)
        f.close()
    return filePath


def get_product_data(productPageUrl, urlLabel = ""):
    productData = []
    shouldRetry = False
    date, time = (get_current_date_time())
    LOG_DATA = []
    try:
        statusCode, html = _fetch_html(productPageUrl)
        if statusCode == 200:
            productData, productDivCount, hasRealProduct, loadingOnly = _extract_products_from_html(
                html, date, time
            )
            LOG_DATA.append(
                "Static parse: product_divs=" + str(productDivCount) +
                " real_products=" + str(len(productData)) +
                " loading_only=" + str(loadingOnly)
            )
            if productDivCount == 0 or hasRealProduct == False:
                LOG_DATA.append("Static HTML had no products, trying rendered HTML")
                rendered_html = _fetch_rendered_html(productPageUrl, LOG_DATA)
                if rendered_html:
                    productData, renderDivs, renderHasReal, renderLoadingOnly = _extract_products_from_html(
                        rendered_html, date, time
                    )
                    LOG_DATA.append(
                        "Rendered parse: product_divs=" + str(renderDivs) +
                        " real_products=" + str(len(productData)) +
                        " loading_only=" + str(renderLoadingOnly)
                    )
                    if renderHasReal == False:
                        debugName = "rendered_" + _slug_from_url(productPageUrl) + ".html"
                        debugPath = _save_debug_html(rendered_html, debugName)
                        LOG_DATA.append("Rendered HTML saved: " + debugPath)
                else:
                    LOG_DATA.append("Rendered HTML not available")
            if urlLabel != "":
                LOG_DATA.append("Data rows for " + urlLabel + ": " + str(len(productData)))
        else:
            LOG_DATA.append("Non-200 status: " + str(statusCode))
    except Exception as e:
        shouldRetry = True
        LOG_DATA.append("EXception occured: " + str(e))
        LOG_DATA.append("Data not found for url = " + productPageUrl)

    write_log(LOG_DATA)
    return productData, shouldRetry



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
    retryList = []
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
        productData, shouldRetry = get_product_data(url[2], url[0])
        if shouldRetry == True or len(productData) == 0:
            sleep(10)
            retryLog = "Retry for url: " + str(url[0])
            write_log([retryLog])
            productData, shouldRetry = get_product_data(url[2], url[0])
        add_new_data_in_csv(filePath, productData)
        sleep(7)


if __name__ == "__main__":
    print("PYTHON CODE STARTED")
    write_log(["script starts for testing github action"])
    sleep(7)
    main()
    write_log(["script ends for testing github action"])