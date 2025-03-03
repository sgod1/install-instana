#!/bin/bash

export PATH=./gen/bin:$PATH

function y() {
   f=$1
   p=$2
   v1=$3

   if [[ "$v1" =~ ^strenv* ]]; then
      ev=`yq --null-input ".a = $v1"`
      v=`echo $ev | yq '.a'`
      echo ... env var $v1 expanded to $v ...
   else
      v=$v1
   fi

   if [[ "$v" =~ ([0-9])$ ]]; then
      echo ... value $v is a number ...
      echo ... path is $p ...
      echo ... file is $f ...

      yq -i "setpath($p|path; $v)" $f
      rc=$?
      echo yq return... $rc

      #yq -i "($p) = $v" $f

   else
      echo ... value $v is a string ...
      echo ... path is $p ...
      echo ... file is $f ...

      yq -i "setpath($p|path; \"$v\")" $f
      rc=$?
      echo yq return... $rc

      #yq -i "($p) = \"$v\"" $f
   fi

   if test $rc -eq 1; then
      echo $f, path not found: $p >> $f.err
   fi
}

function update_path_for_key() {
   path_name=$1 
   profile_key=$2
   env_file=$3
   out_file=$4

   path=`yq ".env[] | select(.name == \"$path_name\") | .path" $env_file | tr -d "\n "`
   vals=`yq ".env[] | select(.name == \"$path_name\") | .values" $env_file | tr -d "-"`

   echo ""
   echo path... $path
   echo vals... $vals

   keys=`yq ".env[] | select(.name == \"$path_name\") | .values | keys" $env_file | tr -d "-"`

   for key in $keys
   do
      echo key... $key, profile-key... $profile_key

      if test "$key" = "$profile_key"
      then

         val=`yq ".env[] | select(.name == \"$path_name\") | .values.$key" $env_file | tr -d " "`

         echo updating path $path with value $val in $out_file

         y "$out_file" "$path" "$val"

	 return 0
      fi
   done

   return 1
}

function display_match_code() {
   match_code=$1
   if test $match_code -eq 0; then echo -n "0 - match"; fi
   if test $match_code -eq 1; then echo -n "1 - no match"; fi
}

function cr_env () {
   template_cr=$1
   env_file=$2
   out_file=$3
   profile=$4

   # truncate error file
   > ${out_file}.err

   path_names=`yq ".env[] | .name" $env_file`

   for path_name in $path_names; do
      echo ===
      echo path name $path_name, env file $env_file

      update_path_for_key $path_name $profile $env_file $out_file
      key_match=$?

      echo ... key_match: $(display_match_code $key_match), path_name $path_name, profile $profile

      if test $key_match -eq 1; then
         update_path_for_key $path_name "default" $env_file $out_file
         key_match=$?

	 echo ... key_match: $(display_match_code $key_match), path_name $path_name, profile "default"

         if test $key_match -eq 1; then
            echo no $profile key or default for the path name $path_name, env file $env_file, template cr $template_cr, using template value
         fi
      fi
   done

   # display error file
   echo ""
   cat ${out_file}.err
}
