
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
    phone: 'Aka',
    name: 'Name',
    comment: 'Comment',
    referrer: 'SuperBuyer',
    referrals: 'BottomBayers',
    operations: 'BonusOperations',
    balance: 'BonusSum',
    shop: 'Shop'
  };

  id: string;
  phone: string;
  name: string;
  comment: string;
  referrer: ParticipantLink;
  referrals: ParticipantLink[];
  operations: BonusAccountOperation[];
  balance: number;

  constructor(serverObject: any = {}) {
    this.id = String(serverObject._id || serverObject.ID || '');
    this.phone = String(serverObject.Aka || '');
    this.name = String(serverObject.Name || '');
    this.comment = String(serverObject.Comment || '');
    this.referrer = new ParticipantLink(serverObject.SuperBuyer);
    if (serverObject.BottomBayers) {
      this.referrals = serverObject.BottomBayers.map(elem => new ParticipantLink(elem));
    }
    if (serverObject.BonusOperations) {
      this.operations = serverObject.BonusOperations.map(elem => new BonusAccountOperation(elem));
    }
    this.balance = parseNumber(serverObject.BonusSum || serverObject.Bonus);
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
