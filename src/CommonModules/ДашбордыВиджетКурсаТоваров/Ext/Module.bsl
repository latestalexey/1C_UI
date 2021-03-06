﻿#Область ПрограммныйИнтерфейс

Процедура Создать (Этот) Экспорт
	
	Этот.ТипДиаграммы = Неопределено;
	ЗадатьНачальныеНастройки(Этот);
	
КонецПроцедуры

Процедура СФормировать(Этот) Экспорт
	
	Для каждого Параметр Из Этот.Параметры Цикл
		
		Если Не ЗначениеЗаполнено(Параметр.Значение) Тогда
			КодОшибки = "ПустыеПараметры";
			СообщитьОбОшибке(КодОшибки);
		КонецЕсли;
		
	КонецЦикла;
	
	СформироватьВиджетКурсовТоваров(Этот);
	
КонецПроцедуры

Процедура РазместитьВИнтерфейсе(Форма, Этот) Экспорт
	
	ИменаСтолбцов = "ВиджетКурсаТоваров%";
	ИменаРодителей = "ГруппаВиджетКурсаТоваров";
	
	ДашбордыФормы.ЗаполнитьЭлементыФормыПоТаблице(Форма, Этот.Результат, ИменаСтолбцов, ИменаРодителей);
	
КонецПроцедуры

#КонецОбласти

Процедура СформироватьВиджетКурсовТоваров(Этот)
	
	ОсновнаяВалюта = ЗапросыВспомогательныеДанные.ПолучитьОсновнуюВалюту();
	ОсновнаяВалютаСимвол = ОсновнаяВалюта.Символ;
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Дата",Этот.Параметры.Дата);
	
	Сутки = 86400;
	// Т.к. в выходные биржа закрыта получаем курс в эти дни на пятницу.
	ДеньДаты = ДеньНедели(Этот.Параметры.Дата);
	Если ДеньДаты = 7 Тогда
		ПредыдущийДень = Сутки *2;
	ИначеЕсли ДеньДаты = 1 Тогда
		ПредыдущийДень = Сутки *3; 
	Иначе
		ПредыдущийДень = Сутки; 
	КонецЕсли;
	
	Запрос.УстановитьПараметр("ПредыдущаяДата",НачалоДня(КонецДня(Этот.Параметры.Дата)-ПредыдущийДень));
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ПоследниеКурсыВалют.Дата,
	|	ПоследниеКурсыВалют.Курс,
	|	ПоследниеКурсыВалют.Символ,
	|	ПоследниеКурсыВалют.Наименование,
	|	ВЫБОР
	|		КОГДА КурсыВалют.Курс ЕСТЬ NULL 
	|			ТОГДА 0
	|		ИНАЧЕ ЕСТЬNULL(ПоследниеКурсыВалют.Курс, 0) - ЕСТЬNULL(КурсыВалют.Курс, 0)
	|	КОНЕЦ КАК РазницаВчерашнийКурс
	|ИЗ
	|	(ВЫБРАТЬ
	|		КурсыТоварныхРынковСрезПоследних.Период КАК Дата,
	|		КурсыТоварныхРынковСрезПоследних.Курс КАК Курс,
	|		КурсыТоварныхРынковСрезПоследних.Валюта.Символ КАК Символ,
	|		КурсыТоварныхРынковСрезПоследних.Номенклатура.Наименование КАК Наименование,
	|		КурсыТоварныхРынковСрезПоследних.Номенклатура КАК Товар
	|	ИЗ
	|		РегистрСведений.КурсыТоварныхРынков.СрезПоследних(&Дата, ) КАК КурсыТоварныхРынковСрезПоследних) КАК ПоследниеКурсыВалют
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыТоварныхРынков КАК КурсыВалют
	|		ПО (КурсыВалют.Период = &ПредыдущаяДата)
	|			И ПоследниеКурсыВалют.Товар = КурсыВалют.Номенклатура"; 
	
	Запрос.Текст = ТекстЗапроса;
	Выборка = Запрос.Выполнить().Выбрать();
	
	РезультатТЗ = Новый ТаблицаЗначений;
	РезультатТЗ.Колонки.Добавить("Заголовок");
	
	Пока Выборка.Следующий() Цикл
		
		ДатаКурса = Новый ФорматированнаяСтрока("Курс на "+ Формат(Выборка.Дата, "ДФ=dd.MM") + Символы.ПС, ШрифтыСтиля.ОбычныйШрифтТекста);
		//Символ = Новый ФорматированнаяСтрока(Выборка.Символ + " ", ШрифтыСтиля.ШрифтГигантский);
		Курс = Новый ФорматированнаяСтрока(ДашбордыФормы.ФорматДенежнойЕдиницы(Выборка.Курс, Выборка.Символ, 2) + Символы.ПС, ШрифтыСтиля.ОченьКрупныйШрифтТекста);
		
		Если Выборка.РазницаВчерашнийКурс >= 0 Тогда
			Разница = Новый ФорматированнаяСтрока("     +"+ Формат(Выборка.РазницаВчерашнийКурс, "ЧДЦ=2") , ШрифтыСтиля.ОбычныйШрифтТекста, ЦветаСтиля.ЦветПоступление);
		ИначеЕсли Выборка.РазницаВчерашнийКурс < 0 Тогда
			Разница = Новый ФорматированнаяСтрока("     -"+ Формат(Выборка.РазницаВчерашнийКурс, "ЧДЦ=2") , ШрифтыСтиля.ОбычныйШрифтТекста, ЦветаСтиля.ЦветСписание);
		КонецЕсли;
		
		Массив = Новый Массив;
		Массив.Добавить(ДатаКурса);
		//Массив.Добавить(Символ);
		Массив.Добавить(Курс);
		Массив.Добавить(Разница);
		
		СтрокаРезультата = РезультатТЗ.Добавить();
		СтрокаРезультата.Заголовок = Новый ФорматированнаяСтрока(Массив);
		
	КонецЦикла;
	
	Этот.Результат = ОбщегоНазначения.ТаблицаЗначенийВМассив(РезультатТЗ);
	
КонецПроцедуры

Процедура ЗадатьНачальныеНастройки(Этот)
	
	Этот.Параметры.Вставить("Дата");

КонецПроцедуры

Процедура СообщитьОбОшибке(КодОшибки)
	
	Если КодОшибки = "ПустыеПараметры" Тогда
		ВызватьИсключение "Не заполнены обязательные параметры дашбордов: Дата"; 
	КонецЕсли;
	
КонецПроцедуры
