using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

public class CryptoCurrency
{
    private const string LogoBaseUrl = "https://s2.coinmarketcap.com/static/img/coins/64x64/";

    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Symbol { get; set; } = string.Empty;
    public int CmcRank { get; set; }
    public double CirculatingSupply { get; set; }
    public double TotalSupply { get; set; }
    public double MaxSupply { get; set; }
    public DateTime DateAdded { get; set; }
    public DateTime LastUpdated { get; set; }
    public int IsActive { get; set; } 
    public string Slug { get; set; } = string.Empty;
    public bool IsAudited { get; set; }
    public string Logo => $"{LogoBaseUrl}{Id}.png";

    public List<AuditInfo> AuditInfoList { get; set; } = new List<AuditInfo>();
    public List<Quote> Quotes { get; set; } = new List<Quote>();
}


public class CryptoCurrencyListResponse
{
    [JsonPropertyName("cryptoCurrencyList")]
    public List<CryptoCurrency> CryptoCurrencyList { get; set; } = new List<CryptoCurrency>();
}

public class DataResponse
{
    public CryptoCurrencyListResponse Data { get; set; } = new CryptoCurrencyListResponse();
}

public class Quote
{
    public double Price { get; set; }
    public double Volume24h { get; set; }
    public double MarketCap { get; set; }
    public double PercentChange1h { get; set; }
    public double PercentChange24h { get; set; }
    public double PercentChange7d { get; set; }
    public double percentChange30d { get; set; }
    public double percentChange60d { get; set; }
    public double percentChange90d { get; set; }
    public double fullyDilluttedMarketCap { get; set; }
    public double marketCapByTotalSupply { get; set; }
    public double dominance { get; set; }
    public double turnover { get; set; }
    public double ytdPriceChangePercentage { get; set; }
    public double percentChange1y { get; set; }
}

public class AuditInfo
{
    [Key] // Add this attribute to specify the primary key
    public int Id { get; set; } // Primary Key
    public string CoinId { get; set; } = string.Empty;
    public string Auditor { get; set; } = string.Empty;
    public int AuditStatus { get; set; }
    public DateTime AuditTime { get; set; }
    public string ReportUrl { get; set; } = string.Empty;
}
