#!/bin/bash

mkdir type
mkdir price
max=$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; select max(source_date) from crypto_source"|awk '
{if ((NR>1)){
	print $1" "$2;}}' )
min=$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; select min(source_date) from crypto_source "|awk '
{if ((NR>1)){
        print $1" "$2;}}' )
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_price group by code having avg(live_price_$)<5' >/home/admin/comp1204labs/type/type5.txt)
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_price group by code having avg(live_price_$) between 5 and 1000' >/home/admin/comp1204labs/type/type1000.txt)
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_price group by code having avg(live_price_$) >=1000' >/home/admin/comp1204labs/type/typemax.txt)
count=$(cat /home/admin/comp1204labs/type/type5.txt|wc -l)
for ((i=1;i<=$count;i++));
do
	c=$(cat /home/admin/comp1204labs/type/type5.txt|sed "${i}q;d");
	$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'live_price_\$','source_date' from crypto_source cs inner join crypto_price cp on cs.source_id=cp.source_id where cp.code="'${c}'"'>'/home/admin/comp1204labs/price/'$c'1.dat');

done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image.png"
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "price($)"
set title "CryptoCurrency Live Price (average<5)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]

plot for [file in system("find ./price -name '*1.dat'")] file using 2:1 w  lp title sprintf(file [9:strstrt(file,".dat")-2])

EOF
count=$(cat /home/admin/comp1204labs/type/type1000.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/type1000.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'live_price_\$','source_date' from crypto_source cs inner join crypto_price cp on cs.source_id=cp.source_id where cp.code="'${c}'"'>'/home/admin/comp1204labs/price/'$c'2.dat');

done


gnuplot <<EOF
set terminal png font "Cambria"
set output "image2.png"
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "price($)"
set title "CryptoCurrency Live Price (average between 5 to 1000)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]

plot for [file in system("find ./price -name '*2.dat'")] file using 2:1 w  lp title sprintf(file [9:strstrt(file,".dat")-2])
EOF

count=$(cat /home/admin/comp1204labs/type/typemax.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/typemax.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'live_price_\$','source_date' from crypto_source cs inner join crypto_price cp on cs.source_id=cp.source_id where cp.code="'${c}'"'>'/home/admin/comp1204labs/price/'$c'3.dat');

done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image3.png"
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "price($)"
set title "CryptoCurrency Live Price (average>1000)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]

plot for [file in system("find ./price -name '*3.dat'")] file using 2:1 w  lp title sprintf(file [9:strstrt(file,".dat")-2])
EOF


gnuplot <<EOF
set terminal png font "Cambria"
set output "image4.png"
set term png size 1000,1500
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "price($)"
set title "CryptoCurrency Live Price"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
set multiplot layout 3,1
plot for [file in system("find ./price -name '*1.dat'")] file using 2:1 w  lp title sprintf(file [9:strstrt(file,".dat")-2])
plot for [file in system("find ./price -name '*2.dat'")] file using 2:1 w  lp title sprintf(file [9:strstrt(file,".dat")-2])
plot for [file in system("find ./price -name '*3.dat'")] file using 2:1 w  lp title sprintf(file [9:strstrt(file,".dat")-2])
unset multiplot
EOF

rm -r price
mkdir trade
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_trade group by 'code' having avg(trade_activity_pct) > (select avg(trade_activity_pct) from crypto_trade)' >/home/admin/comp1204labs/type/typeAbove.txt)
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_trade group by 'code' having avg(trade_activity_pct) < (select avg(trade_activity_pct) from crypto_trade)' >/home/admin/comp1204labs/type/typeBelow.txt)
count=$(cat /home/admin/comp1204labs/type/typeAbove.txt|wc -l)
for ((i=1;i<=$count;i++));
do
	c=$(cat /home/admin/comp1204labs/type/typeAbove.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'trade_activity_pct','source_date' from crypto_source cs inner join crypto_trade ct on cs.source_id=ct.source_id where ct.code="'${c}'"'>'/home/admin/comp1204labs/trade/'$c'1.dat');
done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image5.png"
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "trade activity(%)"
set title "CryptoCurrency Trade Activity (> average)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
plot for [file in system("find ./trade -name '*1.dat'")] file using 2:1 w  lp title sprintf(file [9:strstrt(file,".dat")-2])

EOF

count=$(cat /home/admin/comp1204labs/type/typeBelow.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/typeBelow.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'trade_activity_pct','source_date' from crypto_source cs inner join crypto_trade ct on cs.source_id=ct.source_id where ct.code="'${c}'"'>'/home/admin/comp1204labs/trade/'$c'2.dat');
done
 
gnuplot <<EOF
set terminal png font "Cambria"
set output "image6.png"
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "trade activity(%)" 
set title "CryptoCurrency Trade Activity (< average)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
plot for [file in system("find ./trade -name '*2.dat'")] file using 2:1 w  lp title sprintf(file [9:strstrt(file,".dat")-2])
 
EOF

gnuplot <<EOF
set terminal png font "Cambria"
set output "image7.png"
set term png size 1000,1500
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "trade activity(%)"
set title "CryptoCurrency Trade Activity"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
set multiplot layout 2,1
plot for [file in system("find ./trade -name '*1.dat'")] file using 2:1 w  lp title sprintf(file [9:strstrt(file,".dat")-2])
plot for [file in system("find ./trade -name '*2.dat'")] file using 2:1 w  lp title sprintf(file [9:strstrt(file,".dat")-2])
unset multiplot
EOF
rm -r trade

mkdir tradeVol
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_trade group by 'code' having avg(trade_volume_$) between ((select avg(trade_volume_$) from crypto_trade)/2) and (select avg(trade_volume_$) from crypto_trade)'>/home/admin/comp1204labs/type/typeVolUpper.txt)
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_trade group by 'code' having avg(trade_volume_$) > (select avg(trade_volume_$) from crypto_trade)' >/home/admin/comp1204labs/type/typeVolAbove.txt)
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_trade group by 'code' having avg(trade_volume_$) < ((select avg(trade_volume_$) from crypto_trade)/2)'>/home/admin/comp1204labs/type/typeVolLower.txt)
count=$(cat /home/admin/comp1204labs/type/typeVolUpper.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/typeVolUpper.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'trade_volume_\$','source_date' from crypto_source cs inner join crypto_trade ct on cs.source_id=ct.source_id where ct.code="'${c}'"'>'/home/admin/comp1204labs/tradeVol/'$c'1.dat');

done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image8.png"
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "trade volume($)"
set title "CryptoCurrency Trade Volume (between average/2 and average)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
plot for [file in system("find ./tradeVol -name '*1.dat'")] file using 2:1 w  lp title sprintf(file [12:strstrt(file,".dat")-2])

EOF

count=$(cat /home/admin/comp1204labs/type/typeVolLower.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/typeVolLower.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'trade_volume_\$','source_date' from crypto_source cs inner join crypto_trade ct on cs.source_id=ct.source_id where ct.code="'${c}'"'>'/home/admin/comp1204labs/tradeVol/'$c'2.dat');

done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image9.png"    
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "trade volume($)"
set title "CryptoCurrency Trade Volume (<average/2)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
plot for [file in system("find ./tradeVol -name '*2.dat'")] file using 2:1 w  lp title sprintf(file [12:strstrt(file,".dat")-2])

EOF

count=$(cat /home/admin/comp1204labs/type/typeVolAbove.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/typeVolAbove.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'trade_volume_\$','source_date' from crypto_source cs inner join crypto_trade ct on cs.source_id=ct.source_id where ct.code="'${c}'"'>'/home/admin/comp1204labs/tradeVol/'$c'3.dat');

done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image10.png"    
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "trade volume($)"
set title "CryptoCurrency Trade Volume (>average)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
plot for [file in system("find ./tradeVol -name '*3.dat'")] file using 2:1 w  lp title sprintf(file [12:strstrt(file,".dat")-2])

EOF

gnuplot <<EOF
set terminal png font "Cambria"
set output "image11.png"    
set term png size 2000,1500
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "trade volume($)"
set title "CryptoCurrency Trade Volume"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
set multiplot layout 2,2
plot for [file in system("find ./tradeVol -name '*1.dat'")] file using 2:1 w  lp title sprintf(file [12:strstrt(file,".dat")-2])
plot for [file in system("find ./tradeVol -name '*2.dat'")] file using 2:1 w  lp title sprintf(file [12:strstrt(file,".dat")-2])
plot for [file in system("find ./tradeVol -name '*3.dat'")] file using 2:1 w  lp title sprintf(file [12:strstrt(file,".dat")-2])
unset multiplot

EOF
rm -r tradeVol

mkdir marketCap
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_market_cap group by 'code' having avg(market_capitalization) >= ((select avg(market_capitalization) from crypto_market_cap)/2)'>/home/admin/comp1204labs/type/typeCapAbove.txt)
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_market_cap group by 'code' having avg(market_capitalization) < ((select avg(market_capitalization) from crypto_market_cap)/2)'>/home/admin/comp1204labs/type/typeCapLow.txt)
count=$(cat /home/admin/comp1204labs/type/typeCapLow.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/typeCapLow.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'market_capitalization','source_date' from crypto_source cs inner join crypto_market_cap cm on cs.source_id=cm.source_id where cm.code="'${c}'"'>'/home/admin/comp1204labs/marketCap/'$c'1.dat');

done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image12.png"    
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "market capitalization($)"
set title "CryptoCurrency Market Capitalization (<average/2)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
plot for [file in system("find ./marketCap -name '*1.dat'")] file using 2:1 w  lp title sprintf(file [13:strstrt(file,".dat")-2])

EOF

count=$(cat /home/admin/comp1204labs/type/typeCapAbove.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/typeCapAbove.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'market_capitalization','source_date' from crypto_source cs inner join crypto_market_cap cm on cs.source_id=cm.source_id where cm.code="'${c}'"'>'/home/admin/comp1204labs/marketCap/'$c'2.dat');

done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image13.png"    
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "market capitalization($)"
set title "CryptoCurrency Market Capitalization (>=average/2)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
plot for [file in system("find ./marketCap -name '*2.dat'")] file using 2:1 w  lp title sprintf(file [13:strstrt(file,".dat")-2])
EOF

gnuplot <<EOF
set terminal png font "Cambria"
set output "image14.png"    
set term png size 1000,1500
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "market capitalization($)"
set title "CryptoCurrency Market Capitalization"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
set multiplot layout 2,1
plot for [file in system("find ./marketCap -name '*1.dat'")] file using 2:1 w  lp title sprintf(file [13:strstrt(file,".dat")-2])
plot for [file in system("find ./marketCap -name '*2.dat'")] file using 2:1 w  lp title sprintf(file [13:strstrt(file,".dat")-2])
unset multiplot

EOF

rm -r marketCap

mkdir supply
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_supply group by 'code' having avg(supply) < ((select avg(supply) from crypto_supply)/10000)' > /home/admin/comp1204labs/type/typeSupply1.txt)
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_supply group by 'code' having avg(supply) between ((select avg(supply) from crypto_supply)/10000) and (select avg(supply) from crypto_supply)' > /home/admin/comp1204labs/type/typeSupply2.txt)
$(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select distinct 'code' from crypto_supply group by 'code' having avg(supply) > (select avg(supply) from crypto_supply)' > /home/admin/comp1204labs/type/typeSupply3.txt)

count=$(cat /home/admin/comp1204labs/type/typeSupply1.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/typeSupply1.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'supply','source_date' from crypto_source cs inner join crypto_supply csp on cs.source_id=csp.source_id where csp.code="'${c}'"'>'/home/admin/comp1204labs/supply/'$c'1.dat');


done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image15.png"    
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "supply"
set title "Circulating CryptoCurrency Supply (<average/10000)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
plot for [file in system("find ./supply -name '*1.dat'")] file using 2:1 w  lp title sprintf(file [10:strstrt(file,".dat")-2])
EOF

count=$(cat /home/admin/comp1204labs/type/typeSupply2.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/typeSupply2.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'supply','source_date' from crypto_source cs inner join crypto_supply csp on cs.source_id=csp.source_id where csp.code="'${c}'"'>'/home/admin/comp1204labs/supply/'$c'2.dat');

done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image16.png"    
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "supply"
set title "Circulating CryptoCurrency Supply (between average/10000 and average)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
plot for [file in system("find ./supply -name '*2.dat'")] file using 2:1 w  lp title sprintf(file [10:strstrt(file,".dat")-2])
EOF

count=$(cat /home/admin/comp1204labs/type/typeSupply3.txt|wc -l)
for ((i=1;i<=$count;i++));
do
        c=$(cat /home/admin/comp1204labs/type/typeSupply3.txt|sed "${i}q;d");
        $(/opt/lampp/bin/mysql -u root -N -e 'use crypto_currency; select 'supply','source_date' from crypto_source cs inner join crypto_supply csp on cs.source_id=csp.source_id where csp.code="'${c}'"'>'/home/admin/comp1204labs/supply/'$c'3.dat');

done

gnuplot <<EOF
set terminal png font "Cambria"
set output "image17.png"    
set term png size 1000,1000
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "supply"
set title "Circulating CryptoCurrency Supply (>average)"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
plot for [file in system("find ./supply -name '*3.dat'")] file using 2:1 w  lp title sprintf(file [10:strstrt(file,".dat")-2])
EOF

gnuplot <<EOF
set terminal png font "Cambria"
set output "image18.png"    
set term png size 1000,1500
set xlabel "datetime" offset 0,-1,0
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set ylabel "supply"
set title "Circulating CryptoCurrency Supply"
set xrange['$min' to '$(date '+%Y-%m-%d %T'  -d "$max + 2 day")']
set yrange[0:]
set multiplot layout 3,1
plot for [file in system("find ./supply -name '*1.dat'")] file using 2:1 w  lp title sprintf(file [10:strstrt(file,".dat")-2])
plot for [file in system("find ./supply -name '*2.dat'")] file using 2:1 w  lp title sprintf(file [10:strstrt(file,".dat")-2])
plot for [file in system("find ./supply -name '*3.dat'")] file using 2:1 w  lp title sprintf(file [10:strstrt(file,".dat")-2])
unset multiplot
EOF

rm -r supply
rm -r type
