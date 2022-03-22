#!/bin/zsh
cd `dirname $0`

#cat tenpo code var
tenpo=($(ls -1t ../Raw/*.har | head -1 | gxargs grep -om 1 'a725489'))

#String composition
kakudai=($(find ../Raw -maxdepth 1 -type f -name '*.har' | gxargs grep -E 'pageMax\\\"\:\d\}\"' | sed 's/ //g' | sed -E 's/\\\\/\\/g' ))

#echo $kakudai  using$tenpo ""& ver without delimiter  to 1Sentence 1machine 2days
echo $kakudai | sed 's/ /\n/g' | tr -d \"\:\\\ | sed 's/YMD_biz//g' | sed -E 's/\\out\\//g' | sed -E 's/\\\\202[0-9]{5}},//g' | sed 's/\\value\\//g' | sed -E 's/null/0/g' | sed -E "s/(.*)2日前.*/\1,$tenpo/g" | tee kakudai.txt


#trimming null to 0 'dai','model','BB','RB','Rotation','max','difference','date','holl'
cat kakudai.txt | sed -E 's/.*cd_dai\\\\([0-9]{4})\\,.*name\\\\(.+)\\,\\cd_ps.*BIG\\,\\item\\(\[.*\])},{\\title\\\\REG\\,\\item\\(\[.*\])},0,{.*累計ゲーム\\,\\item\\(\[.*\])},{\\title.*(本日.*,\\\\202[0-9]{5},\\L\\true).*(1日前.*,\\\\202[0-9]{5},\\L\\true).*(a[0-9]{6}).*/\1,\2,BIG\3,REG\4,ST\5,\6,\7,\8/g' | tee kakudai1.txt

＃Select date and to 'dai','Rotation','BB','RB','difference','max','model','holl','date'
echo "   When did you get it? Bfore AM7:00? (y/N): "
if read -q; then
	cat kakudai1.txt | sed -E 's/^([0-9]{4}),(.*),BIG\[([0-9]+),.*REG\[([0-9]+),.*ST\[([0-9]+),.*本日.*{([0-9]+),([-0-9]+),\\\\(202[0-9]{5}),\\L\\true,1日前.*(a[0-9]{6}).*/\1,\5,\3,\4,\7,\6,\2,\9,\8/g' | tee forsort.txt
else
	cat kakudai1.txt | sed -E 's/^([0-9]{4}),(.*),BIG\[[0-9]+,([0-9]+),.*REG\[[0-9]+,([0-9]+),.*ST\[[0-9]+,([0-9]+),.*1日前.*{([0-9]+),([-0-9]+),\\\\(202[0-9]{5}),\\L\\true,.*(a[0-9]{6}).*/\1,\5,\3,\4,\7,\6,\2,\9,\8/g' | tee forsort.txt
fi

#前半整える
#cat kakudai.txt | sed -E 's/^Raw,(a[0-9]{6}),.*cd_dai\\\\([0-9]{4})\\,.*name\\\\(.+)\\,\\cd_ps.*BIG\\,\\item\\(\[.*\])},{\\title\\\\REG\\,\\item\\(\[.*\])},0,{.*累計ゲーム\\,\\item\\(\[.*\])},{\\title.*(本日.*,\\\\202[0-9]{5},\\L\\true).*/\1,\2,\3,\4,\5,\6,\7/g'


#1line trimming null to 0 BIG REG ST kaketai.txt
#echo $kakudai | sed 's/ /\n/g' | tr -d \"\:\\\ | sed 's/YMD_biz//g' | sed -E 's/\\out\\//g' | sed -E 's/\\\\202[0-9]{5}},//g' | sed 's/\\value\\//g' | sed -E 's/null/0/g' | sed -E 's/^Raw,(a[0-9]{6}),.*cd_dai\\\\([0-9]{4})\\,.*name\\\\(.+)\\,\\cd_ps.*BIG\\,\\item\\(\[.*\])},{\\title\\\\REG\\,\\item\\(\[.*\])},0,{.*累計ゲーム\\,\\item\\(\[.*\])},{\\title.*(本日.*,\\\\202[0-9]{5},\\L\\true).*/\1,\2,\3,BIG\4,REG\5,ST\6,\7/g' | tee kakudai.txt

#Sed to $kakedai1 \2\3 本日,\4\5 1日前,\6\7 2日前,
#kakudai1=($(cat kakudai.txt | sed -E 's/^(.*),(本日).*({.+\\\\202[0-9]{5},\\L\\true).*(1日前).*({.+\\\\202[0-9]{5},\\L\\true).*(2日前).*({.+\\\\202[0-9]{5},\\L\\true).*(3日前)\\(.*)/\1,\2\3,\4\5,\6\7,\8\9/g'))
#2/3当日空だとエラーになる
#kakudai1=($(cat kakudai.txt | sed -E 's/^(.*),(本日).*datas\\(.+),\\scrollbar.*(1日前).*({.+\\\\202[0-9]{5},\\L\\true).*(2日前).*({.+\\\\202[0-9]{5},\\L\\true).*(3日前)\\(.*)/\1,\2\3,\4\5,\6\7,\8\9/g'))



#-E no escape \2\3 3日前,\4\5 4日前,\6\7 5日前,\8\9 6日前 to kakudai1.txt
#echo -E $kakudai1 | sed -E 's/ /\n/g' | sed -E 's/^(.*),(3日前).*({.+\\\\202[0-9]{5},\\L\\true).*(4日前).*({.+\\\\202[0-9]{5},\\L\\true).*(5日前).*({.+\\\\202[0-9]{5},\\L\\true).*(6日前).*({.+\\\\202[0-9]{5},\\L\\true).*/\1,\2\3,\4\5,\6\7,\8\9/g' | tee kakudai1.txt

#y/N to kakudai.txt \2dai,\6Rotation,\4BB,\5RB,\8difference,\7max,\3machine,\1holl,\9date
#echo "   When did you get it? Bfore AM7:00? (y/N): "
#if read -q; then
	cat kakudai1.txt | sed -E 's/^(a[0-9]{6}),([0-9]{4}),(.*),BIG\[([0-9]+),.*REG\[([0-9]+),.*ST\[([0-9]+),.*本日.*\{([0-9]+),([-0-9]+),\\\\(202[0-9]{5}),.*,1日前.*/\2,\6,\4,\5,\8,\7,\3,\1,\9/g' | tee kakudai.txt
#else
	cat kakudai1.txt | sed -E 's/^(a[0-9]{6}),([0-9]{4}),(.*),BIG\[[0-9]+,([0-9]+),.*REG\[[0-9]+,([0-9]+),.*ST\[[0-9]+,([0-9]+),.*1日前\{([0-9]+),([-0-9]+),\\\\(202[0-9]{5}),.*/\2,\6,\4,\5,\8,\7,\3,\1,\9/g' | tee kakudai.txt
#fi

#sort unique daibanloop
sort -uk 1n -t "," forsort.txt | > forcheck.txt
er=($( cut -f 1 -d "," forcheck.txt ))
daiban="null"
for ((i=1;i<1+`echo ${#er[*]}`;i++))
do
test $daiban = null && daiban=$er[i]
if [ $daiban -eq $er[i] ]; then
echo "ok$er[i]"
daiban=$((daiban + 1))
else
	while [ $daiban -ne $er[i] ]
	do
	echo $daiban
	daiban=`expr 1 + $daiban`
	done
daiban=`expr 1 + $daiban`
echo "ok$er[i]"
fi
done

python name.py

#touch ../`date +%d%H%M-%S`.csv
#newcsv=$(ls -1t ../*.csv | head -1)
#echo -n to empty

exit
