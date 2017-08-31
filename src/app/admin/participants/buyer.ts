// Цены на сборный груз
export class Buyer {
  constructor(
    public SuperBuyer?: Buyer,
    public ID?: string,
    // Номер телефона
    public Aka?: string,
    // имя
    public Name?: string,
    // Коментарий
    public Comment?: string,
    public LinesForDel?: any,
    public objectId?: string,
  ) { }
}
