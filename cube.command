#!/bin/zsh
cd `dirname $0`

#cat hallcode code var
hallcode=($(ls -1t ../Raw/*.har | head -1 | gxargs grep -om 1 'a725489'))

#String composition
segment=($(find ../Raw -maxdepth 1 -type f -name '*.har' | gxargs grep -E 'pageMax\\\"\:\d\}\"' | sed 's/ //g' | sed -E 's/\\\\/\\/g' ))

"""
echo $segment  Character conversion, trim, 0 replacement, $ hallcode expansion at the end (using ""), and sed to process
dai number, ROT, BIG, REG, model name (model) ,hallcode to trim_seg.txt
"""
echo $segment | sed 's/ /\n/g' | tr -d \"\:\\\ | sed 's/YMD_biz//g' | sed -E 's/\\out\\//g' | sed -E 's/\\\\202[0-9]{5}},//g' | sed 's/\\value\\//g' | sed -E 's/null/0/g' | sed "/pageMax/s/$/$hallcode/g" | sed -E 's/.*cd_dai\\\\([0-9]{4})\\,.*name\\\\(.+)\\,\\cd_ps.*BIG\\,\\item\\(\[.*\])},{\\title\\\\REG\\,\\item\\(\[.*\])},0,{.*累計ゲーム\\,\\item\\(\[.*\])},{\\title\\\\最終(.*)/\1,ROT\5,BIG\3,REG\4,\2,\6/g' | tee trim_seg.txt

"""
From trim_seg.txt, dai number, ROT, BIG, REG, difference number (1111 is yesterday on  0000 is today), MAX(except a of hallcode), model name (model), hallcode (for python), Temporary datet to pre_out.txt

The purpose is to be able to check the serial number and model name while preventing errors in processing the difference number of sheets.
"""
echo "today?(y/N): "
if read -q; then
	cat trim_seg.txt | sed -E 's/^([0-9]{4}),ROT\[([0-9]+,).*BIG\[([0-9]+,).*REG\[([0-9]+,).*\],(.*),ゲーム.*pageMax.*a([0-9]{6}).*/\1,\2\3\40000,\6,\5,\6,20227777/g' | tee pre_out.txt

else
	cat trim_seg.txt | sed -E 's/^([0-9]{4}),ROT\[[0-9]+,([0-9]+,).*BIG\[[0-9]+,([0-9]+,).*REG\[[0-9]+,([0-9]+,).*\],(.*),ゲーム.*pageMax.*a([0-9]{6}).*/\1,\2\3\41111,\6,\5,\6,20227777/g' | tee pre_out.txt

fi

#sort unique daibanloop
sort -uk 1n -t "," pre_out.txt | > pre_out_topy.txt
er=($( cut -f 1 -d "," pre_out_topy.txt ))
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


#date discrimination from pre_out.txt. from trim_seg.txt to pre_diff.txt
#posdai,max,difference,hall
#If there is a number "{0,0,\\20220407,\L\true}],\scrollbar\"
#regex .*{(.+),\\\\202[0-9]{5},\\L\\true}\],\\scrollbar.*1日前
#If not "datas\[],\scrollbar"
#regex .*(\[\]),\\scrollbar.*6日前
#In case of [], replace with 0,0


selector=($(grep -om 1 -e '0000' -e '1111' pre_out.txt))
echo $selector

if [[ $selector -eq 0000 ]]; then
	echo 'today'
	cat trim_seg.txt | sed -E 's/^([0-9]{4}),ROT.*(\[.*\]),\\scrollbar.*1日前.*pageMax.*a([0-9]{6}).*/\1,\2,\3/g' | sed -E 's/^([0-9]{4}),.*{(.+),\\\\202[0-9]{5},\\L\\true}\],(.*).*/\1,\2,\3/g' | sed -E 's/\[\]/0,0/g' | > pre_diff.txt
elif [[ $selector -eq 1111 ]]; then
	echo 'yesterday'
	cat trim_seg.txt | sed -E 's/^([0-9]{4}),ROT.*(\[.*\]),\\scrollbar.*2日前.*pageMax.*a([0-9]{6}).*/\1,\2,\3/g' | sed -E 's/^([0-9]{4}),.*{(.+),\\\\202[0-9]{5},\\L\\true}\],(.*).*/\1,\2,\3/g' | sed -E 's/\[\]/0,0/g' | > pre_diff.txt
else
	echo 'error!!!!'
fi

sort -uk 1n -t "," pre_diff.txt | > diff_topy.txt


#cat trim_seg.txt | sed -E 's/^([0-9]{4}),ROT.*(\[.*\]),\\scrollbar.*1日前.*pageMax.*a([0-9]{6}).*/\1,\2,\3/g' | sed -E 's/^([0-9]{4}),.*{(.+),\\\\202[0-9]{5},\\L\\true}\],(.*).*/\1,\2,\3/g' | sed -E 's/\[\]/0,0/g' | > pre_diff.txt

#cat trim_seg.txt | sed -E 's/^([0-9]{4}),ROT.*(\[.*\]),\\scrollbar.*2日前.*pageMax.*a([0-9]{6}).*/\1,\2,\3/g' | sed -E 's/^([0-9]{4}),.*{(.+),\\\\202[0-9]{5},\\L\\true}\],(.*).*/\1,\2,\3/g' | sed -E 's/\[\]/0,0/g' | > pre_diff.txt








"""
Eerror checking
Check the number of characters per line in diff_topy.txt, add the number of characters to the end of the line, and go to var_length.
make error`date "+%Y%m%d_%H%M%S"`.txt
"""
var_length=($(cat diff_topy.txt | while read line; do echo  $line,$((`echo $line | wc -m` - 1)); done))

err=()
for var in ${var_length}; do
	if [[ ${#var} -gt 30 ]]; then
		echo ${var}
		err+=(${var})
	fi
done

if [[ $#err -ne " " ]]; then
	echo $err | sed 's/ /\n/g' | grep -E '^[0-9]{4}' | > error`date "+%Y%m%d_%H%M%S"`.txt
	echo 'エラーファイルを出力しました(途中終了)'
	exit
fi

python name.py

#touch ../`date +%d%H%M-%S`.csv
#newcsv=$(ls -1t ../*.csv | head -1)
#echo -n to empty

#Empty the contents of the file
echo -n > diff_topy.txt
echo -n > pre_diff.txt
echo -n > pre_out.txt
echo -n > pre_out_topy.txt
echo -n > trim_seg.txt

echo "正常終了"

exit





