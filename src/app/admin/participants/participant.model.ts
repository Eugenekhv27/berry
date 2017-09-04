export class Participant {
  constructor(
    public referrer?: Participant,
    public ID?: string,
    public phone?: string,
    public Name?: string,
    public Comment?: string,
    public LinesForDel?: any,
    public objectId?: string,
  ) { }
}
