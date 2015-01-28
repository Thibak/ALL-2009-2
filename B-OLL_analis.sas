/*кариотип*/

/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*****************                                                                       *******************/
/****************                      Отчет по протоколу ОЛЛ-2009                        ******************/
/*****************                                                                       *******************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
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
run;



/*------------------------------------------*/

proc means data = &LN..all_pt N;
	var new_gendercode;
   title 'Всего записей';
run;

proc freq data=&LN..new_pt ; *информация о количестве;
   tables oll_class / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип';
   FORMAT oll_class oc_f.;
run;

proc freq data=&LN..new_pt;
   tables new_gendercodename / nocum;
   title 'Пол для всей группы';
run;

title1 "b-Oll";

proc means data = &LN..boll n median max min ;
   var age;
   title 'Возраст больных (медиана, разброс)';
run;

/*proc freq data=&LN..boll ;*/
/*   tables age / nocum;*/
/*   title 'Возраст, группы';*/
/*   format age age_group_f.;*/
/*run;*/

proc freq data=&LN..boll ;
   tables new_gendercodename / nocum;
   title 'Пол';
run;

proc sort data = &LN..boll;
	by new_oll_class;
run;

proc freq data=&LN..boll ; *информация о количестве;
   tables new_oll_classname / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип (детально)';
/*   FORMAT T_class12 new_oll_classname.;*/
run;

proc means data=&LN..boll n median max min ;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели";
run;
/**/
/*proc means data=&LN..boll n median max min ;*/
/*	by T_class12;*/
/*	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;*/
/*	title "Общие лабораторные показатели (по имунофенотипам)";*/
/*	FORMAT T_class12 T_class12_f.;*/
/*run;*/

proc freq data=&LN..boll ; *информация о количестве;
   tables new_oll_classname*new_citogenname / nocum;
/*NOPERCENT;*/
   title 'Выполнена цитогенеттика';
/*   FORMAT T_class12 T_class12_f.;*/
run;



proc freq data = &LN..bcito;
	tables new_oll_classname*new_normkariotipname/nocum;
   title 'Нормальный кариотип (из измеренных)';
/*   FORMAT T_class12 T_class12_f.;*/
run;

proc freq data = &LN..bcito;
	tables new_oll_classname*new_mitozname/nocum;
   title 'Нет митозов (из измеренных)';
/*   FORMAT T_class12 T_class12_f.;*/
run;


proc freq data=&LN..boll ; *информация о количестве;
   tables new_oll_classname*new_neyrolekname / nocum;
/*NOPERCENT;*/
   title 'Поражение ЦНС';
/*   FORMAT T_class12 T_class12_f.;*/
run;

proc freq data=&LN..boll ; *информация о количестве;
   tables new_oll_classname*new_uvsredostenname / nocum;
/*NOPERCENT;*/
   title 'Увеличение средостения';
/*   FORMAT T_class12 T_class12_f.;*/
run;

proc freq data=&LN..boll ;
   tables new_oll_classname*FRint/ nocum;
   title 'Достижение ремиссии (по фазам)';
   format FRint FRint_f.;
run;

proc freq data=&LN..boll ;
   tables new_oll_classname*i_ind_death/ nocum;
   title 'Смерть на индукции';
   format i_ind_death y_n.;
run;

proc freq data=&LN..boll ;
   tables new_oll_classname*rem_death/ nocum;
   title 'Смерть в ремиссии';
   format rem_death y_n.;
run;

proc freq data=&LN..boll ;
   tables new_oll_classname*i_res/ nocum;
   title 'Случаев резистентности';
   format i_res y_n.;
run;


proc freq data=&LN..boll ;
   tables new_oll_classname*TR/ nocum;
   title 'Результат лечения';
   format TR TR_f.;
run;



proc freq data=&LN..boll;
   tables new_oll_classname*tkm_au_al/ nocum;
   title 'ауто/алло-ТКМ';
   format tkm_au_al tkm_au_al_f.;
run;

proc freq data=&LN..boll;
   tables new_oll_classname*new_splenomegname/ nocum;
   title 'Акроспленомегалия';
run;

proc freq data=&LN..boll;
   tables new_oll_classname*new_group_riskname/ nocum;
   title 'Распределение по группам риска';
run;

proc freq data=&LN..boll;
   tables new_blast_km/ nocum;
   title 'бластных клеток в КМ';
   format new_blast_km blast_km_f.;
run;




/* общую и безрецидивную по возрасту, центрам,
группам риска, цитогенетике (нормальный и аномальный кариотип), 
подтипам (В1,2,3) для всех В-ОЛЛ вместе*/

%eventan (&LN..boll, TLive, i_death, 0,,&y,,,"Выживаемость");
%eventan (&LN..boll, TRF, iRF, 0,,&y,,,"Безрецидивная выживаемость");

%eventan (&LN..boll, TLive, i_death, 0,,&y,new_oll_classname,,"Выживаемость");
%eventan (&LN..boll, TRF, iRF, 0,,&y,new_oll_classname,,"Безрецидивная выживаемость");

%eventan (&LN..boll, TLive, i_death, 0,,&y,age, age_group_f.,"Общая выживаемость");
%eventan (&LN..boll, TRF, iRF, 0,,&y, age, age_group_f.,"Безрецидивная выживаемость");

%eventan (&LN..boll, TLive, i_death, 0,,&y,reg,reg_f.,"Выживаемость");
%eventan (&LN..boll, TRF, iRF, 0,,&y,reg,reg_f.,"Безрецидивная выживаемость");

%eventan (&LN..boll, TLive, i_death, 0,,&y,new_group_riskname,,"Выживаемость");
%eventan (&LN..boll, TRF, iRF, 0,,&y,new_group_riskname,,"Безрецидивная выживаемость");


data tmp;
	set all2009.boll;
	if new_t411 = 1;
run;

%eventan (tmp, TLive, i_death, 0,,&y,,,"Выживаемость");
%eventan (tmp, TRF, iRF, 0,,&y,,,"Безрецидивная выживаемость");
