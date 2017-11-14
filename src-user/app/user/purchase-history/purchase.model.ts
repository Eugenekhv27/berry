
interface PurchaseDetail {
  article: string;
  money: number;
}

export interface Purchase {
  id: string;
  date: Date;
  shop: string;
  points: number;
  money: number;
  rating: number;
  details: PurchaseDetail[];
  detailsSummary: string;
}
