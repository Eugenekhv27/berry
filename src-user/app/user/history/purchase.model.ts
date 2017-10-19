
interface PurchaseDetail {
  article: string;
  money: number;
}

export interface Purchase {
  date: string;
  shop: string;
  points: number;
  money: number;
  rating: number;
  details: PurchaseDetail[];
  detailsSummary: string;
}
