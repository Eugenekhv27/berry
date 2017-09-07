export class Participant {

  // соответствие имен здесь именам на сервере
  static readonly onServer = {
    referrer: 'SuperBuyer',
    phone: 'Aka',
  };

  constructor(
    public referrer?: Participant,
    public ID?: string,
    public phone?: string,
    public Name?: string,
    public Comment?: string,
    public LinesForDel?: any,
    public objectId?: string,
    public Bonus?: string | number
  ) { }

  static replacePropertyName(o: any, oldName: string, newName: string): any {
    o[newName] = o[oldName];
    delete o[oldName];
    return o;
  }

  static mapAllPropertyNames(fn: any) {
    Object.getOwnPropertyNames(Participant.onServer).map(fn);
  }

  convertForServer(o: any = this): any {
   const copy = Object.assign({}, o);
    Participant.mapAllPropertyNames(
      key => Participant.replacePropertyName(copy, key, Participant.onServer[key])
    );
    return copy;
  }

  /**
   * convertForFront
   *  Заменяет имена свойств объекта Buyer, полученного с сервера,
   *  на их аналоги для Participant, принятые в клиентском приложении
   */
  convertForFront(o: any = this): Participant {
    Participant.mapAllPropertyNames(
      key => Participant.replacePropertyName(o, Participant.onServer[key], key)
    );
    return o;
  }

  json(): string {
    return JSON.stringify(this);
  }
}
