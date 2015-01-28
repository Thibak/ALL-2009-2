/*идентификатор компа*/ *D - sony, Z - ГНЦ;
*Без предефайна оказывается не работает;
%let disk = .;
%let lastname= .;
%macro what_OC;
%if &sysscpl = W32_7PRO %then 
	%do;
		%let disk = D; *sony;
	%end;
%if &sysscpl = X64_7PRO %then 
	%do;
		%let disk = Z; *работа;
	%end;
%mend;


/*определитель ОС*/
/*data comp;*/
/*	OC = "&sysscpl";*/
/*run;*/
/**/
/*proc print data = COMP;*/
/*run;*/
%what_OC;

%let LN = ALL2009; * имя библиотеки;
Libname &LN "&disk.:\AC\OLL-2009\SAS"; * Библиотека данных;
%let y = cl;


data &LN..zalina_up;
	set &LN..new_pt ;
	if  age > 55;
run;

proc print data =  &LN..zalina_up;
	var pt_id name age;
run;

proc means data = &LN..zalina_up n median max min ;
   var age;
   title 'Возраст больных (медиана, разброс) >55';
run;

data &LN..zalina;
	set &LN..new_pt ;
	if age >= 50 and age <= 55;
run;

proc means data = &LN..zalina n median max min ;
   var age;
   title 'Возраст больных (медиана, разброс) 50<=x<=55';
run;

proc sort data=&LN..zalina;
	by pt_id;
run;

proc print data=&LN..zalina;
	var pt_id name age;
run;

proc freq data=&LN..zalina; *информация о количестве;
   tables oll_class / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип';
   FORMAT oll_class oc_f.;
run;

proc freq data=&LN..zalina;
   tables new_gendercodename / nocum;
   title 'Пол';
run;

proc freq data=&LN..zalina ; *информация о количестве;
   tables new_oll_classname / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип (детально)';
run;


proc freq data=&LN..zalina ; *информация о количестве;
   tables new_group_riskname / nocum;
/*NOPERCENT;*/
   title 'Группа риска';
run;

proc means data=&LN..zalina n median max min ;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для ХТ 50-55";
run;

proc sort data=&LN..zalina;
	by oll_class;
run;

proc means data=&LN..zalina n median max min ;
	by oll_class;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для ХТ 50-55 (по классам)";
    FORMAT oll_class oc_f.;
run;

proc means data=&LN..zalina_up n median max min ;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для ХТ >55";
run;

proc sort data=&LN..zalina_up;
	by oll_class;
run;

proc means data=&LN..zalina_up n median max min ;
	by oll_class;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для ХТ >55 (по классам)";
    FORMAT oll_class oc_f.;
run;

proc freq data=&LN..zalina ; *информация о количестве;
   tables new_neyrolekname / nocum;
/*NOPERCENT;*/
   title 'Поражение ЦНС';
run;

proc freq data=&LN..zalina; *информация о количестве;
   tables new_uvsredostenname / nocum;
/*NOPERCENT;*/
   title 'Увеличение средостения';
run;

proc freq data=&LN..zalina;
   tables FRint/ nocum;
   title 'Достижение ремиссии (по фазам)';
   format FRint FRint_f.;
run;

proc freq data=&LN..zalina;
   tables i_ind_death/ nocum;
   title 'Смерть на индукции';
   format i_ind_death y_n.;
run;

proc freq data=&LN..zalina ;
   tables i_res/ nocum;
   title 'Случаев резистентности';
   format i_res y_n. ;
run;

proc freq data=&LN..zalina;
   tables TR/ nocum;
   title 'Результат лечения';
   format TR TR_f.;
run;


%eventan (&LN..zalina, TLive, i_death, 0,,&y,,,"Выживаемость");
%eventan (&LN..zalina, TRF, iRF, 0,,&y,,,"Безрецидивная выживаемость");
%eventan (&LN..zalina, Trel, i_rel, 0,F,&y,,,"Ландмарк анализ. Вероятность развития рецидива");
