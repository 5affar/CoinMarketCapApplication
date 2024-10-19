public class CryptoCurrencyDbModel
{
    private const string LogoBaseUrl = "https://s2.coinmarketcap.com/static/img/coins/64x64/";
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Symbol { get; set; } = string.Empty;
    public int CmcRank { get; set; }
    public double CirculatingSupply { get; set; }
    public double TotalSupply { get; set; }
    public double MaxSupply { get; set; }
    public double Price { get; set; }
    public double MarketCap { get; set; }
    public double Volume24h { get; set; }
    public double PercentChange1h { get; set; }
    public double PercentChange24h { get; set; }
    public double PercentChange7d { get; set; }
    public string Logo => $"{LogoBaseUrl}{Id}.png";
}
