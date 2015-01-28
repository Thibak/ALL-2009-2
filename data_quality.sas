/*Менеджмент качества данных*/


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

proc print data = &LN..cens split='*' N;
	var pt_id name;
	label pt_id = 'Номер пациента*в протоколе'
          name = 'Имя*в базе пациентов';
	title "Из базы принудительно исключены следующие записи" ;
run;

proc print data = &LN..age_out;
	var  pt_id name age; 
	title  'По возрасту исключены';
run; 


data null;
	set &LN..all_pt;
	if pt_id = . then output;
run;

proc print data = null split='*' N;
	var pt_id name;
	label pt_id = 'Номер пациента*в протоколе'
          name = 'Имя*в базе пациентов';
	title "В базе не имеют номера в протоколе" ;
run;


proc print data = &LN..error_ptVSet split='*' N obs="Номер*ошибки";
	var pt_id name name_e new_etap_protokolname it1 it2;
	label pt_id = 'Номер пациента*в протоколе'
          name = 'Имя*в базе пациентов'
          name_e = 'Имя*в базе этапов'
		  new_etap_protokolname = 'этап'
		  it1 = 'Запись*в базе пациентов' 
		  it2 = 'Запись* в базе этапов';
	title "Ошибки в базе (пара пациент - этап)" ;
	format  it1 it2 it_f. ; 
run;

proc sort data = &LN..error_timeline;
	by pt_id;
run;

proc print data = &LN..error_timeline split='*' N;
	var pt_id name time_error;
	label pt_id = 'Номер пациента*в протоколе'
          name = 'Имя*в базе пациентов'
		  time_error = "Ошибки";
	title "ошибки заполнения таймлайна" ;
	footnote '*дата последнего визита обнавлена в соответствии с имеющейся информацией о лечении'; 
	format  it1 it2 it_f. time_error time_error_f. ; 
run;
footnote " ";


proc sort data = &LN..no_TR;
	by pt_id;
run;


proc print data = &LN..no_TR;
	var pt_id name;
	title 'Нет результатов лечения для следующих пациентов';
run;

proc sort data = &LN..new_pt;
	by TD;
run;

proc print data = &LN..new_pt;
	var pt_id name TD lastdate pr_b;
	title "Срок наблюдения";
run;

proc means data = &LN..all_pt N;
	var new_birthdate;
   title 'Всего записей';
run;

/**/
/*-----------------------------------------------*/
/*Блок проверки заполнения цитогенетики*/
/*---------------------------------------------*/
data tmp;
	set &LN..new_pt;
	if no_cito = 1 and new_citogen = 1;
run;

proc sort  data = tmp;
	by pt_id;
run;

proc print data = tmp;
	var pt_id name;
run;

proc sort data=all2009.all_pt;
	by new_citogen;
run;


proc freq data=all2009.all_pt;
	by new_citogen;
	table new_normkariotipname*new_mitozname/nocum;
	title 'Нет митозов, неоднозначность';
run;




proc freq data=all2009.all_pt;
	by new_citogen;
	table new_normkariotipname*new_t922name*new_bcrablname*new_t411name new_anomal_oth/nocum;
	title 'Цитогенетика';
run;


proc freq data=all2009.all_pt;
	table new_citogenname/nocum;
	title 'Цитогенетика';
run;

proc freq data=all2009.all_pt;
	table new_citogenname*new_normkariotipname/nocum;
	title 'Цитогенетика';
run;

data tmp;
	set all2009.all_pt;
	if new_citogen = 1;
run;

proc sort data=tmp;
	by new_normkariotip pt_id;
run;

proc print data=tmp;
	var pt_id name new_normkariotipname new_mitozname new_t922name new_bcrablname new_t411name new_anomal_oth ;
run;