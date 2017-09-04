
rastamat: 現成的MFCC程式碼(http://www.ee.columbia.edu/~dpwe/resources/matlab/rastamat/)
wav: 自己錄的音檔，5組數字0到5
fsdd: Free Spoken Digit Dataset，一個英文數字的dataset(https://github.com/Jakobovski/free-spoken-digit-dataset)

main.matlab: 指定一個音檔，與一組template音檔算距離，並畫圖
main2.matlab: 指定一個音檔，與多組template音檔算距離，並畫圖
main3.matlab: 同樣內容音檔的彼此距離，以及全部音檔彼此的距離，並將結果分別寫入hw3_check.txt、hw3_result.txt中
my_hamming.m: 漢明窗函數
my_epd.m: 端點偵測函數
my_mfcc.m: MFCC函數(各個frame分別有39為特徵向量)
dtw_grid_c.m: Dynamic Time Warping的遞迴作法
