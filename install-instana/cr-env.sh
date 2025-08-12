#!/bin/bash

export PATH=./gen/bin:$PATH

__key_match=0
__key_no_match=1

__yq_path_found=2
__yq_path_not_found=3

function y() {
   local f=$1
   local p=$2
   local v1=$3
   local yqrc=0

   if [[ "$v1" =~ ^strenv* ]]; then
      ev=`./gen/bin/yq --null-input ".a = $v1"`
      v=`echo $ev | ./gen/bin/yq '.a'`
      echo ... env var $v1 expanded to $v ...
   else
      v=$v1
   fi

   if [[ "$v" =~ (^[0-9]+)([0-9]*$) ]]; then
      echo ... value $v is a number ...
      echo ... path is $p ...
      echo ... file is $f ...

      ./gen/bin/yq -i "setpath($p|path; $v)" $f
      yqrc=$?
      echo yq return... $yqrc

      #./gen/bin/yq -i "($p) = $v" $f

   elif [[ "$v" == "true" || "$v" == "false" ]]; then
      echo ... value $v is a boolean ...
      echo ... path is $p ...
      echo ... file is $f ...

      ./gen/bin/yq -i "setpath($p|path; $v)" $f
      yqrc=$?
      echo yq return... $yqrc

   else
      echo ... value $v is a string ...
      echo ... path is $p ...
      echo ... file is $f ...

      ./gen/bin/yq -i "setpath($p|path; \"$v\")" $f
      yqrc=$?
      echo yq return... $yqrc

      #./gen/bin/yq -i "($p) = \"$v\"" $f
   fi

   if test $yqrc -eq 1; then
      echo $f, path not found: $p >> $f.err
      return $__yq_path_not_found
   fi

   return $__yq_path_found
}

function update_path_for_key() {
   local path_name=$1 
   local profile_key=$2
   local env_file=$3
   local out_file=$4

   local path=`./gen/bin/yq ".env[] | select(.name == \"$path_name\") | .path" $env_file | tr -d "\n "`
   local vals=`./gen/bin/yq ".env[] | select(.name == \"$path_name\") | .values" $env_file | tr -d "-"`

   echo ""
   echo path... $path
   echo vals... $vals

   local keys=`./gen/bin/yq ".env[] | select(.name == \"$path_name\") | .values | keys | .[] comments=\"\"" $env_file | tr -d "-"`

   for key in $keys
   do
      echo key... $key, profile-key... $profile_key

      if [[ $key == $profile_key ]]
      then

         val=`./gen/bin/yq ".env[] | select(.name == \"$path_name\") | .values.$key" $env_file | tr -d " "`

         echo updating path $path with value $val in $out_file

         y "$out_file" "$path" "$val"
	 yrc=$?

	 if (( $yrc == $__yq_path_not_found )); then
	   return $__yq_path_not_found
	 fi

	 return $__key_match
      fi
   done

   return $__key_no_match
}

function display_match_code() {
   local match_code=$1
   if test $match_code -eq $__key_match; then echo -n "$__key_match - match"; fi
   if test $match_code -eq $__key_no_match; then echo -n "$__key_no_match - no match"; fi
   if test $match_code -eq $__yq_path_not_found; then echo -n "$__yq_path_not_found -  yq path not found"; fi
}

function cr_env () {
   local template_cr=$1
   local env_file=$2
   local out_file=$3
   local profile=$4
   local version=${5:-0}

   # truncate error file
   > ${out_file}.err

   local path_names=`./gen/bin/yq ".env[] | .name" $env_file`

   local is_digit="(^[0-9]+)([0-9]*$)"

   for path_name in $path_names; do
      echo ===
      echo path name $path_name, env file $env_file

      # not_before, not_after, if_true
      not_before=`./gen/bin/yq ".env[] | select(.name == \"$path_name\") | .not_before" $env_file | tr -d " "`
      not_after=`./gen/bin/yq ".env[] | select(.name == \"$path_name\") | .not_after" $env_file | tr -d " "`
      if_true=`./gen/bin/yq ".env[] | select(.name == \"$path_name\") | .if_true" $env_file | tr -d " "`

      if [[ $not_after =~ $is_digit ]] && [[ $version =~ $is_digit ]] && (( $version > $not_after )); then 
         echo "path name $path_name is not applicable after version $not_after, version $version, env file $env_file"
	 continue
      fi

      if [[ $not_before =~ $is_digit ]] && [[ $version =~ $is_digit ]] && (( $version < $not_before )); then 
         echo "path name $path_name is not applicable before version $not_before, version $version, env file $env_file"
	 continue
      fi

      update_path_for_key $path_name $profile $env_file $out_file
      key_match=$?

      echo ... profile-match: $(display_match_code $key_match), path_name $path_name, profile $profile

      if test $key_match -eq $__key_no_match; then
         update_path_for_key $path_name "default" $env_file $out_file
         key_match=$?

	 echo ... default-match: $(display_match_code $key_match), path_name $path_name, profile "default"

         if test $key_match -eq $__key_no_match; then
            echo no $profile key or default for the path name $path_name, env file $env_file, template cr $template_cr, using template value
         fi
      fi
   done

   # display error file
   echo ""
   cat ${out_file}.err

   errc=`cat ${out_file}.err | wc -l`
   if (( $errc > 0 )); then
      return 1
   else
      rm ${out_file}.err
      return 0
   fi
}
