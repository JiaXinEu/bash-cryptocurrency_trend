#!/bin/bash
#get current time
readTime=$(date +"%Y-%m-%d %T")
curl -s https://www.cryptocurrencychart.com>cryptofile.html
$(/opt/lampp/bin/mysql -u root -e "create database if not exists crypto_currency")

$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; create table if not exists crypto_source (source_id int auto_increment, html_source mediumtext ,source_date datetime, primary key (source_id))")
code=$(cat cryptofile.html|sed "s/'/\\\'/g")
$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; insert into crypto_source(html_source, source_date) values('$code','$readTime')" )

#get source id for reference
id=$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; select source_id from crypto_source where source_date='$readTime'"| grep -o '[0-9]*')

#get crypto live price
live=$(cat cryptofile.html|grep \$[0-9]*|cut -d '"' -f 4 )

#get price change
change=$(cat cryptofile.html|grep "Price change"|cut -d'"' -f 14)

#get price change in percentage
changePct=$(cat cryptofile.html|grep "Price change"|cut -d '>' -f 7|cut -d '%' -f 1)

#get crypto name
name=$(cat cryptofile.html|grep '/coin/' |cut -d "<" -f 2| cut -d ">" -f 2|sed 's/ (/-(/g'| cut -d "(" -f 1)

#get crypto name code
code=$(cat cryptofile.html|grep '/coin/' |cut -d '"' -f 2|cut -d '/' -f 5)

#get crypto supply
supply=$(cat cryptofile.html|grep '\$' |cut -d '"' -f 20)

#get trade volume
volume=$(cat cryptofile.html|grep "numeric volume"|cut -d '"' -f 26) 

#get trade activity
activity=$(cat cryptofile.html|grep "numeric health"|cut -d"%" -f 2|cut -d">" -f 7)

#get crypto market capitalization
marketCap=$(cat cryptofile.html|grep "numeric marketCap"|cut -d '"' -f 36)


$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; create table if not exists crypto_type (code varchar(10),name varchar(30),primary key (code))")
$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; create table if not exists crypto_price (code varchar(10), live_price_$ double, change_from_yesterday double, source_id int, primary key(code,source_id),foreign key (code) references crypto_type (code), foreign key (source_id) references crypto_source(source_id)) ")
$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; create table if not exists crypto_trade (code varchar(10),trade_volume_$ double,trade_activity_pct double, source_id int, primary key (code,source_id), foreign key (code) references crypto_type(code), foreign key (source_id) references crypto_source(source_id))")
$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; create table if not exists crypto_supply (code varchar(10), supply double, source_id int, primary key (code, source_id),foreign key (code) references crypto_type(code), foreign key (source_id) references crypto_source(source_id))")
$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; create table if not exists crypto_market_cap (code varchar(10), market_capitalization double, source_id int, primary key (code, source_id), foreign key (code) references crypto_type(code), foreign key (source_id) references crypto_source(source_id))")

#get number of type of cryptocoins collected
count=$(cat cryptofile.html|grep '/coin/' |cut -d '"' -f 2|cut -d '/' -f 5|wc -l)

for i in $(seq $count);
do
	
	insertCode=$(echo $code|cut -d " " -f $((i)))
	insertName=$(echo $name|cut -d "-" -f $((i)))
	insertLive=$(echo $live|cut -d " " -f $((i)))
	insertChange=$(echo $change|cut -d " " -f $((i)))
	insertVolume=$(echo $volume|cut -d " " -f $((i)))
	insertActivity=$(echo $activity|cut -d " " -f $((i)))	
	insertSupply=$(echo $supply|cut -d " " -f $((i)))
	insertCap=$(echo $marketCap|cut -d " " -f $((i)))

	$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; insert into crypto_type(code,name) values('$insertCode','$insertName')" )
	$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; insert into crypto_price(code,live_price_$,change_from_yesterday,source_id) values('$insertCode',$insertLive,$insertChange,$id)" )
	$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; insert into crypto_trade(code,trade_volume_$,trade_activity_pct , source_id) values('$insertCode',$insertVolume,$insertActivity,$id)" )
	$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; insert into crypto_supply(code, supply,source_id) values ('$insertCode',$insertSupply,$id)")
	$(/opt/lampp/bin/mysql -u root -e "use crypto_currency; insert into crypto_market_cap(code,market_capitalization, source_id) values ('$insertCode',$insertCap,$id)")


	if (($(echo $insertChange 0.2 | awk '{if ($1 >= $2) print 1;}'))); then
		pctChange=$(echo $changePct|cut -d " " -f $((i)))
		notify-send  "Cryptocoin Price Rise $(/bin/date "+%H:%M %d/%m")" "$insertCode changed by $(echo $pctChange)";
	elif (($(echo $insertChange -0.2 | awk '{if ($1 <= $2) print 1;}'))); then
		pctChange=$(echo $changePct|cut -d " " -f $((i)))
                notify-send  "Cryptocoin Price Fall $(/bin/date "+%H:%M %d/%m")" "$insertCode changed by $(echo $pctChange)";
	fi

done


