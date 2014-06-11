#!/bin/bash

# http://12stocks.com/stockinfo/Best_Biotech_Stocks.php?symbol=IBB&orderby=marketcap&offset=125#stocktable2
# http://12stocks.com/stockinfo/Best_Biotech_Stocks.php?symbol=IBB&orderby=marketcap&offset=100#stocktable
# http://12stocks.com/stockinfo/Best_Biotech_Stocks.php?symbol=IBB&orderby=marketcap&offset=75#stocktable
# http://12stocks.com/stockinfo/Best_Biotech_Stocks.php?symbol=IBB&orderby=marketcap&offset=50#stocktable
# http://12stocks.com/stockinfo/Best_Biotech_Stocks.php?symbol=IBB&orderby=marketcap&offset=25#stocktable
# http://12stocks.com/stockinfo/Best_Biotech_Stocks.php?symbol=IBB&orderby=marketcap&offset=0#stocktable


root='http://12stocks.com/stockinfo/Best_Biotech_Stocks.php?symbol=IBB&orderby=marketcap&offset='

for i in 0#stocktable 25#stocktable 50#stocktable 75#stocktable 100#stocktable 125#stocktable2 ; do
  wget -O "${i}.html"  -U "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.114 Safari/537.36" ${root}${i}
done

# change names
# from 75#stocktable.html
# to   stocktable-75.html
for i in 0 25 50 75 100 125 ; do 
   f="stocktable-${i}.html"
   f2="${f}.tmp"

   mv ${i}#* $f
   ls -la $f
done

for i in 0 25 50 75 100 125 ; do 
   f="stocktable-${i}.html"
   f2="${f}.tmp"
   links2 -dump -width 200 $f > ${f2}.0.txt
done

for i in 0 25 50 75 100 125 ; do
   f="stocktable-${i}.html"
   f2="${f}.tmp"

   csplit -k -f "${f2}.0.txt." ${f2}.0.txt '%Performance of Stocks in Biotech Index%+3' '/Stocks. Click on arrows to view more/'
   cat ${f2}.0.txt.00      | sed 's/Add.*Watchlist//g'                                                                                                                 > ${f2}.1.extract
   cat ${f2}.1.extract     | sed 's/^[ \t]*//;s/[ \t]*$//'                                                                                                             > ${f2}.2.clean
   #cat ${f2}.2.clean      | awk -F'  +' '{printf "%s %s %s",$1, gensub(/ /,"_","g",$2), gensub(/ /,"_","g",$3); for(i=4; i<=NF; i++) printf " %s",$i; printf "\n"; }' > ${f2}.3.whitespaces
   cat ${f2}.2.clean       | awk -F'  +' '{printf "%s %s %s %s %.2f",$1, gensub(/ /,"_","g",$2), gensub(/ /,"_","g",$3), $4, $4-$4 /($5/100 + 1 ) ; for(i=5; i<=NF; i++) printf " %s",$i; printf "\n"; }' > ${f2}.3.whitespaces
   cat ${f2}.3.whitespaces | sed 's/ \([0-9]\)/ +\1/g' | column -t | sed 's/[+]/ /g'                                                                                   > ${f2}.4.format
done



tmp="health_care_share_listing.tmp.txt"
test -f $tmp && rm $tmp 
echo "Ticker  Stock_Name Category Recent_Day_Price  Day_Change_$ Day_Ch_%  Weekly_Change%   YTD_Change%" > $tmp

for i in 0 25 50 75 100 125 ; do
   f="stocktable-${i}.html"
   f2="${f}.tmp"

   cat ${f2}.4.format >> $tmp
   cat $tmp | sed 's/ \([0-9]\)/ +\1/g' | column -t | sed 's/[+]/ /g' > health_care_share_stats.txt
done

cp health_care_share_stats.txt "health_care_share_stats_$(date +%F.%H:%M%S.%N).txt" 
