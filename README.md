## Develpoing data products - Course Project

#### Description
Sales forecasting is very important for sales and purchases planning. This case is based on real-life data of company selling metal working machines: benders, turning and milling lathes, etc. We can do this by several various methods: time-series forecasting or building a predicting sales volume model based on macroeconomical factors predicted by famous experts.

We compare two approaches to sales forecasting: time-series prediction approach and regression model approach. In regression model approach, we suppose that time is not a predictor, but sales volume depends on current economic climate only, expressed in some popular indexes.

These indexes are well-known GDP rates, currency exchange rate and some indicators from [Russian Union of Industrialists and Entrepreneurs](http://eng.rspp.ru) (RUIE) regular surveys. The historical GDP rates and its official expert predictions are taken from Federal State Statistics Service (FSSS) [official website](http://www.gks.ru/wps/wcm/connect/rosstat_main/rosstat/en/main).
Other indexes predictions were estimated by company experts.

#### Data
The training set contains a historical quarter sales data (in relation to 1st quarter 2011) as outcome and a set of predictors:

* YEAR - string variable (it's never used in regression models and used in correlation pairs only)
* QUARTER - factor variable
* ER - mean quarter exchange rate RUR/USD
* INDX2 - logistics and infrastructure index (RUIE)
* INDX3 - B2B index (RUIE)
* INDX5 - financial markets index (RUIE)
* INDX7 - investment and social activity index (RUIE)
* GDP12 - quarter gross domestic product in relation to the same period of the previous year (FSSS)
* GDP1 - quarter gorss domestic product in realtion to the previous quarter (FSSS)

## Usage

* **Data** tab - shows train and test sets (using googleVis table)
* **Pairs correlations** tab - shows correlogramm between all or selected predictors. You can change the set of predictors on the left pane. Remember that the field YEAR is not used as a predictor in regression model!
* **Model summary** tab - shows summary output of the model. To calculate this model select the model in the field **Choose model** (linear regression or random forest) and press the **Train model** button. After a few seconds, you will see a model summary. If you change set of predictors or model type you should press **Train model** button again to calculate a new model.
* **Forecast plot** tab - shows the plot with historical sales data and two forecasts: by the Holt-Winters method (as a base approach) and by the selected regression model. If uncheck the INDX5 predictor we will obtain very similar predictions.

## Appendix
*Written by Aleksandr Voishchev 12/26/2015.*

