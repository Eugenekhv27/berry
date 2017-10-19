
interface ShopBalance {
  shop: string;
  points: number;
}

export interface Balance {
  dateBegin: Date;
  dateEnd: Date;
  points: number;
  plusPoints: number;
  minusPoints: number;
  details: ShopBalance[];
}
