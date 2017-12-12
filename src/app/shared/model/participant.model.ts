
function parseNumber(n: any) {
  const b = parseFloat(String(n));
  return isNaN(b) ? 0 : b;
}

export class ParticipantLink {
  id: string;
  phone: string;

  /**
   * @param buyer - объект Buyer, полученный от сервера
   */
  constructor(buyer?: any) {
    if (buyer) {
      this.id = String(buyer._id || '');
      this.phone = String(buyer.Aka || '');
    }
  }
}

export class BonusAccountOperation {
  static readonly serverClassName = 'doc.BonusOperation';

  id: string; // "_id"
  participant: ParticipantLink; // "Buyer"
  date: string; // "DocDate"
  docUUID: string;  // "ByDocUUID"
  money: number; // "RubSum"
  points: number; // "PointsSum"
  plusPoints: number; // "PlusPointsSum"
  minusPoints: number; // "MinusPointsSum"
  comment: string; // "Comment"

  /**
   * @param op - объект "Операция", полученный от сервера
   */
  constructor(op: any = {}) {
    this.id = String(op._id || '');
    this.participant = new ParticipantLink(op.Buyer);
    this.date = String(op.DocDate || '');
    this.docUUID = String(op.ByDocUUID || '');
    this.money = parseNumber(op.RubSum);
    this.points = parseNumber(op.PointsSum);
    this.plusPoints = parseNumber(op.PlusPointsSum);
    this.minusPoints = parseNumber(op.MinusPointsSum);
    this.comment = String(op.Comment || '');
  }
}

export class Participant {
  // соответствие имен на фронтенде именам на сервере
  static readonly serverClassName = 'ent.Buyer';

  //   _id?: string,
  //   Aka?: string,
  //   Name?: string,
  //   Comment?: string,
  //   SuperBuyer?: Participant,
  //   BottomBayers?: any[],
  //   BonusOperations?: any[],
  //   LinesForDel?: any,
  //   objectId?: string,
  //   Bonus?: number | string,
  //   BonusSum?: number | string,
  //   Shop?: any
  // ) { }
  private static readonly serverClassKeys = {
    id: '_id',
    date: 'RegDate',
    phone: 'Aka',
    name: 'Name',
    age: 'age',
    birthDate: 'BirthDate',
    sex: 'Sex',
    comment: 'Comment',
    referrer: 'SuperBuyer',
    referrals: 'BottomBuyers',
    operations: 'BonusOperations',
    balance: 'BonusSum',
    shop: 'Shop'
  };

  id: string;
  date: string;
  phone: string;
  name: string;
  age: string;
  birthDate: string;
  comment: string;
  referrer: ParticipantLink;
  referrals: ParticipantLink[];
  operations: BonusAccountOperation[];
  balance: number;
  shop: string;
  guestLevel: string;
  abcGroup: string;
  sex: string;

  constructor(serverObject: any = {}) {
    this.id = String(serverObject._id || serverObject.ID || '');
    this.date = String(serverObject.RegDate || '');
    this.phone = String(serverObject.Aka || '');
    this.name = String(serverObject.name || '');
    this.age = String(serverObject.age || '');
    this.birthDate = String(serverObject.BirthDate || '');
    this.guestLevel = String(serverObject.guestLevel || '');
    this.abcGroup = String(serverObject.abcGroup || '');
    this.sex = String(serverObject.Sex || '');
    this.comment = String(serverObject.Comment || '');
    this.referrer = new ParticipantLink(serverObject.SuperBuyer);
    if (serverObject.BottomBuyers) {
      this.referrals = serverObject.BottomBuyers.map(elem => new ParticipantLink(elem));
    }
    if (serverObject.BonusOperations) {
      this.operations = serverObject.BonusOperations.map(elem => new BonusAccountOperation(elem));
    }
    this.balance = parseNumber(serverObject.BonusSum || serverObject.Bonus);
    this.shop = String(serverObject.Shop || '');
  }

  static replacePropertyName(o: any, oldName: string, newName: string): any {
    o[newName] = o[oldName];
    delete o[oldName];
    return o;
  }

  static mapAllPropertyNames(fn: any) {
    Object.getOwnPropertyNames(Participant.serverClassKeys).map(fn);
  }

  convertForServer(o: any = this): any {
   const copy = Object.assign({}, o);
    Participant.mapAllPropertyNames(
      key => Participant.replacePropertyName(copy, key, Participant.serverClassKeys[key])
    );
    return copy;
  }

  json(): string {
    return JSON.stringify(this);
  }
}
