/*http://stackoverflow.com/questions/14684885/how-to-add-new-observation-to-already-created-dataset-in-sas*/
/*программа апдейта данных*/

/*Генерим копию датасета, а потом аппендим его*/
/*вопрос в том, куда аппендить. Похоже, что к конечному датасету All_pt, 
проблема!!! что половина анализа по вычленению данных из сабжа происходит в обработчике...*/
/*В итоге перенес всякие выборки в сам анализ. Не лучшее решение, но пусть будет так. */
/*Плохо то, что другие запросы не будут обновлять данные*/

Видимо надо сначала собиратьданные, а потом запускать их анализ, а потом вывод данных

data _null_;
put 'aaaaajjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjja';
run;