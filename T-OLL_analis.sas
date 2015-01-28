/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*****************                                                                       *******************/
/****************                      Отчет по протоколу ОЛЛ-2009                        ******************/
/*****************                          Только по Т-ОЛЛ                              *******************/
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

title1 "T-Oll";

proc means data = &LN..toll n median max min ;
   var age;
   title 'Возраст больных (медиана, разброс)';
run;

/*proc freq data=&LN..toll ;*/
/*   tables age / nocum;*/
/*   title 'Возраст, группы';*/
/*   format age age_group_f.;*/
/*run;*/

proc freq data=&LN..toll ;
   tables new_gendercodename / nocum;
   title 'Пол';
run;

proc sort data = &LN..toll;
	by T_class12;
run;

proc freq data=&LN..toll ; *информация о количестве;
   tables T_class12 / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип (детально)';
   FORMAT T_class12 T_class12_f.;
run;

proc means data=&LN..toll n median max min ;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для ХТ";
run;

proc means data=&LN..toll n median max min ;
	by T_class12;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели (по имунофенотипам)";
	FORMAT T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ; *информация о количестве;
   tables T_class12*new_citogenname / nocum;
/*NOPERCENT;*/
   title 'Выполнена цитогенеттика';
   FORMAT T_class12 T_class12_f.;
run;



proc freq data = &LN..tcito;
	tables T_class12*new_normkariotipname/nocum;
   title 'Нормальный кариотип (из измеренных)';
   FORMAT T_class12 T_class12_f.;
run;

proc freq data = &LN..tcito;
	tables T_class12*new_mitozname/nocum;
   title 'Нет митозов (из измеренных)';
   FORMAT T_class12 T_class12_f.;
run;

/*для ландмарка посмотреть нормальный кариотип &LN..tLMcito*/

/*proc freq data = &LN..tLMcito;*/
/*	tables T_class12*new_mitozname/nocum;*/
/*   title 'Нет митозов (из измеренных) для LM';*/
/*   FORMAT T_class12 T_class12_f.;*/
/*run;*/

proc freq data=&LN..toll ; *информация о количестве;
   tables T_class12*new_neyrolekname / nocum;
/*NOPERCENT;*/
   title 'Поражение ЦНС';
   FORMAT T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ; *информация о количестве;
   tables T_class12*new_uvsredostenname / nocum;
/*NOPERCENT;*/
   title 'Увеличение средостения';
   FORMAT T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*FRint/ nocum;
   title 'Достижение ремиссии (по фазам)';
   format FRint FRint_f. T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*i_ind_death/ nocum;
   title 'Смерть на индукции';
   format i_ind_death y_n. T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*i_res/ nocum;
   title 'Случаев резистентности';
   format i_res y_n. T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*TR/ nocum;
   title 'Результат лечения';
   format TR TR_f. T_class12 T_class12_f.;
run;



proc freq data=&LN..toll;
   tables T_class12*tkm_au_al/ nocum;
   title 'ауто/алло-ТКМ';
   format tkm_au_al tkm_au_al_f. T_class12 T_class12_f.;
run;

data tmp;
	set &LN..toll;
	if tkm_au_al in (1,2) and i_death = 1;
run;

proc print data = tmp;
	title 'ТКМ + смерть (проверить последовательность событий)';
	var pt_id name tkm_au_al i_death date_TKM date_death;
	 format date_TKM DDMMYY10. date_death DDMMYY10. tkm_au_al tkm_au_al_f.;
run; 

data tmp;
	set &LN..toll;
	if date_death - pr_b < 10 and date_death ne .;
run;

proc print data = tmp;
	title 'Смерть менее чем через 10 дней после начала лечения';
	var pt_id name pr_b date_death new_group_riskname new_oll_classname ;
	 format pr_b DDMMYY10. date_death DDMMYY10. tkm_au_al tkm_au_al_f.;
run; 

data tmp;
	set all2009.toll;
	if new_uvsredosten or new_peref_ulu or new_vnutrigrud_ulu or new_abdomi_ulu;
run;

proc sort data = tmp;
	by blast_km;
run;

proc freq data = tmp;
	tables blast_km/nocum;
	FORMAT  blast_km blast_km_f.;
	title 'Бласты в КМ для пациентов у кого один из факторов положительный: Увеличение средостения (Клинические проявления), Периферические (увеличение лим. Узлов),
Внутригрудные (увеличение лим. Узлов), Абдоминальные (увеличение лим. Узлов), Размер (увеличение лим. Узлов)';
run;

proc means data=tmp n median max min ;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для пациентов с бластами в крови и пр. как в предыдущем запросе";
	FORMAT T_class12 T_class12_f.;
run;

proc means data=tmp n median max min ;
	by blast_km;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для пациентов с бластами в крови и пр. как в предыдущем запросе";
	FORMAT T_class12 T_class12_f. blast_km blast_km_f.;
run;

proc sort data = tmp;
	by  T_class12 blast_km;
run;

proc means data=tmp n median max min ;
	by  T_class12 blast_km;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для пациентов с бластами в крови и пр. как в предыдущем запросе";
	FORMAT T_class12 T_class12_f. blast_km blast_km_f.;
run;
%eventan (&LN..toll, TLive, i_death, 0,,&y,,,"Выживаемость");
%eventan (&LN..toll, TRF, iRF, 0,,&y,,,"Безрецидивная выживаемость");

%eventan (&LN..toll, TLive, i_death, 0,,&y,blast_km, blast_km_f.,"Выживаемость");
%eventan (&LN..toll, TRF, iRF, 0,,&y,blast_km, blast_km_f.,"Безрецидивная выживаемость");

%eventan (&LN..toll, TLive, i_death, 0,,&y,age,age_group_f.,"Выживаемость");
%eventan (&LN..toll, TRF, iRF, 0,,&y,age,age_group_f.,"Безрецидивная выживаемость");

%eventan (&LN..toll, TLive, i_death, 0,,&y,T_class12,T_class12_f.,"Выживаемость");
%eventan (&LN..toll, TRF, iRF, 0,,&y,T_class12,T_class12_f.,"Безрецидивная выживаемость");

%eventan (&LN..toll_LM_xa, TLive_LM, i_death, 0,,&y,tkm_au_al, tkm_au_al_f.,"Ландмарк анализ. Общая выживаемость");
%eventan (&LN..toll_LM_xa, TRF_LM, iRF, 0,,&y, tkm_au_al, tkm_au_al_f.,"Ландмарк анализ. Безрецидивная выживаемость");
%eventan (&LN..toll_LM_xa, Trel_LM, i_rel, 0,F,&y,tkm_au_al, tkm_au_al_f.,"Ландмарк анализ. Вероятность развития рецидива");


data tmp;
	SET &LN..toll_LM;
	if tkm_au_al = 0;
run;

%eventan (tmp, TLive_LM, i_death, 0,,&y,age, age_group_f.,"Только ХТ: Ландмарк анализ. Общая выживаемость");
%eventan (tmp, TRF_LM, iRF, 0,,&y, age, age_group_f.,"Только ХТ: Ландмарк анализ. Безрецидивная выживаемость");



proc sort data=&LN..toll_LM_xa;
	by i_tkm tkm_dur;
run;

/*proc print data=tmp;*/
/*	var pt_id name i_tkm tkm_dur tkm_au_al pr_b date_tkm ;*/
/*run;*/

proc means data=&LN..toll_LM_xa n median max min ;
	var tkm_dur;
	title 'От начала лечения до трансплантации';
run;

proc means data=&LN..toll_LM_xa n median max min ;
	var Ttkm;
	title 'От достижения ремиссии до трансплантации';
run;

/*Группа ХТ до 6-ти мес.*/
/*data tmp;*/
/*	set &LN..toll;*/
/*	if Tlive < 6;*/
/*	label date_death = "Дата смерти"*/
/*		new_group_risk = "группа риска"*/
/*		new_normkariotip = "Normal karyotype"*/
/*		pt_id = "идентификатор"*/
/*		name = "имя"*/
/*		i_death = "смерть"*/
/*		i_ind_death = "смерть в индукции"*/
/*		i_rel = "рецидив"*/
/*		i_dev = "отклонение от протокола"*/
/*		dev_t = "отклонения - комментарий"*/
/*		i_off = "преждевременное снятие с протокола"*/
/*		off_t = "снятие -- комментарий"*/
/*		;*/
/*run;*/
/**/
/*proc print data=tmp;*/
/*	var pt_id name i_death i_ind_death i_rel i_dev dev_t i_off off_t; */
/**/
/*run;*/

/**/
/*proc sort data=&LN..toll;*/
/*	by i_death TLive;*/
/*run;*/
/**/
/*proc print data=all2009.toll;*/
/*	var pt_id name i_death TLive;*/
/*run;*/

/*proc means data = &LN..new_pt median max min ;*/
/*   var TD;*/
/*   title 'Среднее время наблюдения';*/
/*run;*/
/**/
/*proc sort data = &LN..new_pt;*/
/*	by tkm_au_al;*/
/*run;*/
/**/
/*proc means data = &LN..new_pt median max min ;*/
/*	by tkm_au_al;*/
/*   var TD;*/
/*   title 'Среднее время наблюдения по группам';*/
/*run;*/



/*proc sort data=&LN..all_pt;*/
/*	by new_oll_class;*/
/*run;*/
/**/
/*proc means data = &LN..new_pt median max min ;*/
/*   var Ttkm;*/
/*   title 'Среднее кол. мес. до ТКМ (медиана, разброс)';*/
/*run;*/
/*proc freq data=&LN..all_pt ORDER = DATA;*/
/*   tables new_oll_classname / nocum;*/
/*   title 'Иммунофенотип (детально)';*/
/*run;*/

proc sort data=&LN..toll_NLM;
	by i_death TLive;
run;

proc print data=&LN..toll_NLM;
	var pt_id name i_death TLive TRF i_rem i_rel onT;
	title "Не LM";
run;

data tmp;
	SET &LN..toll_LM;
	if i_tkm;
run;

proc sort data=tmp;
	by tkm_au_al;
run;

/*proc print data=tmp;*/
/*	var pt_id name Ttkm tkm_au_al;*/
/*run;*/

proc means data=tmp n median max min ;
	var Ttkm;
	title 'Для ТКМ, медиана от ремиссии до ТКМ';
run;

proc means data=tmp n median max min ;
	by tkm_au_al;
	var Ttkm;
	format tkm_au_al tkm_f.;
run;

proc sort data=tmp;
	by reg;
run;

proc means data=tmp n median max min ;
	by reg;
	var Ttkm;
	format reg reg_f.;
run;


data tmp;
	set all2009.toll_lm_xa;
	if i_rel = 1;
run;

proc print data=tmp;
	var pt_id name new_regionname new_group_riskname new_oll_classname owneridname i_death;
	title "Рецедивы LM";
run;

proc freq data = all2009.toll_lm_xa;
	tables blast_km*tkm_au_al/nocum;
	FORMAT  blast_km blast_km_f. tkm_au_al tkm_au_al_en.;
	title 'Бласты в КМ';
run;

proc freq data = all2009.toll_lm;
	table T_class12*new_normkariotipname/nocum;
   title 'Нормальный кариотип для LM';
   format T_class12 T_class12_f.;
run; 


proc ttest data=&LN..toll_LM_xa;
	class tkm_au_al;
	var new_l;
	title "Гипотеза о влиянии лейкоцитов на принятия решения о лечении";
	FORMAT tkm_au_al tkm_au_al_en.;
run;


data off;
	set all2009.toll_LM_xa;
	if i_dev = 1;
run;

proc print data=off;
	var pt_id name i_rel i_death;
run;