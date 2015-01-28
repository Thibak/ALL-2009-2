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

%let LN = ALL2009; * имя библиотеки;
Libname &LN "&disk.:\AC\OLL-2009\SAS"; * Библиотека данных;
%let y = cl;
%let cens = (20,73,25);
/*Исключаем - Марханова, Позднякова, Чубукова*/
/*25 -- Марханов (Марханов был снят с протокола еще в 10-м году (его лечили бог знает как).)*/
/*73 -- Чубуков (у Чубукова вообще другой диагноз - миелоидная саркома)*/
/*266	Дмитровский В.Б. -- Дмитровского не надо исключать - у него только правильно не отмечено время достижения полной ремиссии и дата ТКМ. Он правильный больной с неправильными датами*/
/*20	Поздняков Нет данных Нет данных*/
/*27 -- Головнитцына -- Головнитцына включена, но умерла до лечения. Ее исходне данные можно включать, а в анализе выживаемости и результатах лечения не участвует.*/
*20, 27, 99, 132, 258, 264;

%macro Eventan(dat,T,C,i,s,cl,f,for, ttl);
/*
dat -имя набора данных,
T - время,
C - индекс события/цензурирования,
i=0, если с индекс события,
i=1, если с индекс цензурирования.
s = пусто,если строится кривая выживаемости
s = F, если строится кривая накопленной вероятности
cl = cl,если показывать доверительный интервал
cl = пусто,если не показывать доверительный интервал
s = F, если строится кривая накопленной вероятности
f = фактор (страта) ЕСЛИ ПУСТО ТО БЕЗ СТРАТЫ
for = формат (1.0 для целочисленных значаний, когда нет специального формата)
ttl = заголовок
*/

data _null_; set &dat;
   length tit1 $256 tit2 $256;
*чтение лейболов;
tit1=vlabel(&T);
%if &f ne %then %do; tit2=vlabel(&f);%end;
   * положили лейбала в макропеременную;
   call symput('tt1',tit1);
   call symput('tt2',tit2);
output;
   stop;
   keep tit1 tit2;
run;
title1 &ttl;
title2 " зависимая:  &tt1 // фактор       :  &tt2";
ods graphics on;
ods exclude WilHomCov LogHomCov HomStats  Quartiles ; *ProductLimitEstimates;
proc lifetest data=&dat plots =(s( &s &cl))  method=pl ;
    %if &f ne %then %do; strata &f/test=logrank;
    id &f;format   &f &for;%end;
    time &T*&C(&i) ;
run;
ods graphics off;
%mend;


/*------------------------------------------------------------------------------------------*/

proc format;
    value oc_f  1 = "B-клеточный" 2 = "T-клеточный" 3 = "Бифенотипический" 0 = "Неизвестен" ;
    value gender_f 1 = "Мужчины" 2 = "Женщины";
    value risk_f 1 = "Стандартная" 2 = "Высокая" 3 = "нет данных";
    value age_group_28_f low-28 = "до 28-ми лет" 28-high = "после 28-ми лет";
    value age_group_30_f low-30 = "до 30-ти лет" 30-high = "после 30-ти лет";
    value age_group_33_f low-33 = "до 33-х лет" 33-high = "после 33-х лет";
	value age_50_f low-49 = "до 50-х лет" 49-high = "старше 50-х лет";
	value age_group_f low-29 = "AYA" 29-high = "Adult";
	value triple_age_f low-30 = "1" 30-40 = "2" 40-high = "3";
	value tkm_f 0="нет" 1="ауто" 2="алло";
	value it_f 1="есть" 0 = "нет";
	value time_error_f . = "нет ошибок" 
		0 = "дата последнего визита не заполнена" 
		1 = "дата последнего события (этапа) больше чем дата последнего контакта" 
		2 = "дата ремиссии больше даты последнего контакта" 
		3 = "дата рецедива больше даты последнего контакта"
		4 = "date bmt > lastdate";

/*	  if date_rem > lastdate then do; time_error = 2; lastdate = date_rem; end;*/
/*    if date_rel > lastdate then do; time_error = 3; lastdate = date_rel; end;*/
	value new_group_risk_f 1 = "стандартная" 2 = "высокая";
	value y_n 0 = "нет" 1 = "да";
	value yn_e 0 = "no" 1 = "yes";
	value au_al_f 1 = "ауто" 2 = "алло - родственная" ;
	value reg_f 0 = "Регионы" 1 = "ГНЦ"; 
	value T_class12_f 0 = "T1+T2" 1 = "T3" 2 = "T4";
	value T_class124_f 0 = "T1+T2+T4" 1 = "T3";
	value TR_f 0 = "Полная ремиссия" 1 = "Резистентная форма" 2 = "Смерть в индукции";
	value BMinv_f 0 = "Без поражения" 1 = "С поражением";
	value AAC_f 0 = "Химиотерапия" 1 = "Ауто ТКМ" 2 = "Алло ТКМ" 3 = "Ранний рецидив" 4 = "Смерть в ремиссии" 5 = "на индукции (T < 5 мес)";
	value FRint_f 1 = "ПР на предфазе" 2 = "ПР на 1-ой фазе индукции" 3 = "ПР на 2-ой фазе индукции" 19 = "Контролькое обследование";
	value BMT_f 0 = "Химиотерапия" 1 = "ТКМ";
	value tkm_au_al_f 0 = "Химиотерапия" 1="Ауто-ТКМ" 2="Алло-ТКМ";
	value tkm_au_al_en 0 = "chemo" 1="auto-HSCT" 2="allo-HSCT";
	value new_group_riskname_f 1 = 'Standard' 2 = 'Hi';
	value blast_km_f low-5 = '<5%' 5-25 = '5%-25%' 25-high = '>25%';
/*	value pr_bg_year_f = */
run;



/*------------------------------------------*/
proc sort data = &LN..new_pt;
	by age;
run;

proc means data = &LN..new_pt N median max min ;
	var age;
   title 'Всего записей, медиана возраста';
run;

proc means data = &LN..new_pt N median max min ;
	by age;
	var age;
   title 'Всего записей, медиана возраста по группам';
	FORMAT age age_50_f.;
run;

proc freq data=&LN..new_pt;
   tables new_gendercodename / nocum;
   title 'Пол для всей группы';
run;
proc freq data=&LN..new_pt;
   tables new_gendercodename*age / nocum;
   title 'Пол для всей группы';
   FORMAT age age_50_f.;
run;
proc freq data=&LN..new_pt ; *информация о количестве;
   tables oll_class / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип';
   FORMAT oll_class oc_f.;
run;

proc freq data=&LN..new_pt ; *информация о количестве;
   tables oll_class*age / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип';
   FORMAT oll_class oc_f. age age_50_f.;
run;


proc freq data=&LN..new_pt ; *информация о количестве;
   tables new_oll_classname / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип (детально)';
   FORMAT oll_class oc_f.;
run;

proc freq data=&LN..new_pt ; *информация о количестве;
   tables new_oll_classname*age / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип (детально)';
   FORMAT oll_class oc_f. age age_50_f.;
run;

proc means data=&LN..new_pt n median max min;
	by age;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Клинико-лабораторные показатели";
	FORMAT age age_50_f.;
run;

proc freq data=&LN..new_pt ; *информация о количестве;
   tables new_group_riskname*age / nocum;
/*NOPERCENT;*/
   title 'Группа риска';
   FORMAT  age age_50_f.;
run;


proc freq data=&LN..new_pt ; *информация о количестве;
   tables 
age*new_splenomegname 
age*lap
age*new_neyrolekname
age*new_uvsredostenname
/ nocum;
/*NOPERCENT;*/
   title 'Клинические проявления';
   FORMAT  age age_50_f. lap y_n.;
run;

proc freq data=&LN..new_pt ; *информация о количестве;
   tables d_ch*age / nocum;
/*NOPERCENT;*/
   title 'Смена на дексаметазон';
   FORMAT  age age_50_f. d_ch y_n.;
run;

proc freq data=&LN..new_pt ; *информация о количестве;
   tables age*d_ch*new_group_riskname / nocum;
/*NOPERCENT;*/
   title 'Смена на дексаметазон (две таблицы по возрастным группам)';
   FORMAT  age age_50_f. d_ch y_n.;
   label d_ch = 'Смена на дексаметазон';
run;

proc means data = &LN..new_pt N median max min ;
	by age;
	var new_blast_km;
   title 'Бластных клеток в КМ';
   	FORMAT age age_50_f.;
run;

proc freq data=&LN..new_pt ;
   tables age*TR/ nocum;
   title 'Результат лечения';
   format TR TR_f. age age_50_f.;
run;

proc freq data=&LN..new_pt ; *информация о количестве;
   tables 
age*pneumonia_i
age*NEP_i
age*sepsis_i
age*invasp_i
/ nocum;
/*NOPERCENT;*/
   title 'Инфекционные осложнения';
   FORMAT  
	age age_50_f.
	pneumonia_i  y_n.
	NEP_i y_n.
	sepsis_i y_n.
	invasp_i y_n.
	;
run;


proc freq data=&LN..new_pt ; *информация о количестве;
   tables 
age*a_vvod_i
age*a_pankr_i
age*a_gepat_i
age*a_narbelsint_i
age*a_tromb_i
/*a_occhuv_t*/
age*a_perehod_i
age*a_otmena_i
/ nocum;
/*NOPERCENT;*/
   title 'Токсические проявления Аспарагиназы';
   FORMAT  
	age age_50_f.
	a_pankr_i y_n.
	a_gepat_i y_n.
	a_narbelsint_i y_n.
	a_tromb_i y_n.
	a_perehod_i y_n.
	a_otmena_i y_n.
	;
run;

%eventan (&LN..new_pt, TLive, i_death, 0,,&y,,,"Выживаемость");
%eventan (&LN..new_pt, TRF, iRF, 0,,&y,,,"Безрецидивная выживаемость");
%eventan (&LN..new_pt, Trel, i_rel, 0,F,&y,,,"Ландмарк анализ. Вероятность развития рецидива");

%eventan (&LN..new_pt, TLive, i_death, 0,,&y,age, age_50_f.,"Выживаемость");
%eventan (&LN..new_pt, TRF, iRF, 0,,&y,age, age_50_f.,"Безрецидивная выживаемость");
%eventan (&LN..new_pt, Trel, i_rel, 0,F,&y,age, age_50_f.,"Ландмарк анализ. Вероятность развития рецидива");

%eventan (&LN..oll_reg_50, TLive, i_death, 0,,&y,,,"Выживаемость");


/**/
/*data &LN..zalina_up;*/
/*	set &LN..new_pt ;*/
/*	if  age > 55;*/
/*run;*/
/**/
/*proc print data =  &LN..zalina_up;*/
/*	var pt_id name age;*/
/*run;*/
/**/
/*proc means data = &LN..zalina_up n median max min ;*/
/*   var age;*/
/*   title 'Возраст больных (медиана, разброс) >55';*/
/*run;*/
/**/
/*data &LN..zalina;*/
/*	set &LN..new_pt ;*/
/*	if age >= 50 and age <= 55;*/
/*run;*/
/**/
/*proc means data = &LN..zalina n median max min ;*/
/*   var age;*/
/*   title 'Возраст больных (медиана, разброс) 50<=x<=55';*/
/*run;*/
/**/
/*proc sort data=&LN..zalina;*/
/*	by pt_id;*/
/*run;*/
/**/
/*proc print data=&LN..zalina;*/
/*	var pt_id name age;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina; *информация о количестве;*/
/*   tables oll_class / nocum;*/
/*/*NOPERCENT;*/*/
/*   title 'Иммунофенотип';*/
/*   FORMAT oll_class oc_f.;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina;*/
/*   tables new_gendercodename / nocum;*/
/*   title 'Пол';*/
/*run;*/
/**/
/*proc freq data=&LN..zalina ; *информация о количестве;*/
/*   tables new_oll_classname / nocum;*/
/*/*NOPERCENT;*/*/
/*   title 'Иммунофенотип (детально)';*/
/*run;*/
/**/
/**/
/*proc freq data=&LN..zalina ; *информация о количестве;*/
/*   tables new_group_riskname / nocum;*/
/*/*NOPERCENT;*/*/
/*   title 'Группа риска';*/
/*run;*/
/**/
/*proc means data=&LN..zalina n median max min ;*/
/*	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;*/
/*	title "Общие лабораторные показатели для ХТ 50-55";*/
/*run;*/
/**/
/*proc sort data=&LN..zalina;*/
/*	by oll_class;*/
/*run;*/
/**/
/*proc means data=&LN..zalina n median max min ;*/
/*	by oll_class;*/
/*	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;*/
/*	title "Общие лабораторные показатели для ХТ 50-55 (по классам)";*/
/*    FORMAT oll_class oc_f.;*/
/*run;*/
/**/
/*proc means data=&LN..zalina_up n median max min ;*/
/*	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;*/
/*	title "Общие лабораторные показатели для ХТ >55";*/
/*run;*/
/**/
/*proc sort data=&LN..zalina_up;*/
/*	by oll_class;*/
/*run;*/
/**/
/*proc means data=&LN..zalina_up n median max min ;*/
/*	by oll_class;*/
/*	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;*/
/*	title "Общие лабораторные показатели для ХТ >55 (по классам)";*/
/*    FORMAT oll_class oc_f.;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina ; *информация о количестве;*/
/*   tables new_neyrolekname / nocum;*/
/*/*NOPERCENT;*/*/
/*   title 'Поражение ЦНС';*/
/*run;*/
/**/
/*proc freq data=&LN..zalina; *информация о количестве;*/
/*   tables new_uvsredostenname / nocum;*/
/*/*NOPERCENT;*/*/
/*   title 'Увеличение средостения';*/
/*run;*/
/**/
/*proc freq data=&LN..zalina;*/
/*   tables FRint/ nocum;*/
/*   title 'Достижение ремиссии (по фазам)';*/
/*   format FRint FRint_f.;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina;*/
/*   tables i_ind_death/ nocum;*/
/*   title 'Смерть на индукции';*/
/*   format i_ind_death y_n.;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina ;*/
/*   tables i_res/ nocum;*/
/*   title 'Случаев резистентности';*/
/*   format i_res y_n. ;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina;*/
/*   tables TR/ nocum;*/
/*   title 'Результат лечения';*/
/*   format TR TR_f.;*/
/*run;*/
/**/
/**/
/*%eventan (&LN..zalina, TLive, i_death, 0,,&y,,,"Выживаемость");*/
/*%eventan (&LN..zalina, TRF, iRF, 0,,&y,,,"Безрецидивная выживаемость");*/
/*%eventan (&LN..zalina, Trel, i_rel, 0,F,&y,,,"Ландмарк анализ. Вероятность развития рецидива");*/
