import { Injectable } from '@angular/core';
import { DataService, NotifierService } from '../../services/services';
import { TableRow, DetailsRow } from './bonus-turnover.model';

import { appParseNumber } from '../../../shared/utils';

@Injectable()
export class BonusTurnoverService {

  constructor(
    private dataService: DataService,
    private notifier: NotifierService,
  ) {}

  getMainReportData(startDate: Date, endDate: Date) {
    console.log('BonusTurnoverService::getMainReportData()', startDate, endDate);

    return this.dataService.getBonusReport(startDate, endDate)
      .map((data: any) => {
        const reportData = {
          tableRows: {},
          tableTotals: {
            plusBonus: 0,
            minusBonus: 0
          }
        };

        reportData.tableRows = data.rows.map(dataRow => new TableRow(dataRow));
        reportData.tableTotals.plusBonus = appParseNumber(data.totals.PlusBonus);
        reportData.tableTotals.minusBonus = appParseNumber(data.totals.MinusBonus);

        return reportData;
      });
  }

  getDetailedReportData(date: Date) {
    console.log('BonusTurnoverService::getDetailedReportData()', date);

    return this.dataService.getBonusReportDetails(date)
      .map((data: any) => {
        console.log(data);
        const reportData = {
          table: {},
          totals: {
            plusBonus: 0,
            minusBonus: 0
          }
        };

        reportData.table = data.rows.map(dataRow => new DetailsRow(dataRow));
        reportData.totals.plusBonus = appParseNumber(data.totals.PlusPointsSum);
        reportData.totals.minusBonus = appParseNumber(data.totals.MinusPointsSum);

        return reportData;
      });
  }
}
