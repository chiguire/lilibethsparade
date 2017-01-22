class WaitingTicks
{
  private int ticks = -1;
  private int maxTicks = -1;
  
  WaitingTicks() {}
  
  public void setNoWaiting()
  {
    ticks = -1;
    maxTicks = -1;
  }
  
  public void setWaitingTicks(int maxTicks)
  {
    ticks = 0;
    this.maxTicks = maxTicks;
  }
  
  public void increase()
  {
    if (ticks < maxTicks)
    {
      ticks++;
    }
  }
  
  public boolean triggered()
  {
    return maxTicks != -1 && ticks == maxTicks;
  }
  
  public String toString()
  {
    return "(" + ticks + "/" + maxTicks + ": " + triggered() + ")";
  }
}