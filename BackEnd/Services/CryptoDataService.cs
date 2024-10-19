using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;

public class CryptoDataService
{
    private readonly string _connectionString;

    public CryptoDataService(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task FetchAndUpdateData()
    {
        HttpService httpService = new HttpService();
        DataResponse? dataResponse = await httpService.GetCryptoCurrencyDataAsync("https://api.cmcap.io/data-api/v3/cryptocurrency/listing?convertIds=2781,1&start=1&limit=100&sortType=desc&sortBy=rank&rankRange=100&aux=cmc_rank,date_added,max_supply,circulating_supply,total_supply,self_reported_circulating_supply,self_reported_market_cap");

        if (dataResponse?.Data?.CryptoCurrencyList != null)
        {
            await UpdateDatabaseAsync(dataResponse.Data.CryptoCurrencyList);
            Console.WriteLine("Database updated successfully.");
        }
        else
        {
            Console.WriteLine("Failed to retrieve or process cryptocurrency data.");
        }
    }

    private async Task UpdateDatabaseAsync(List<CryptoCurrency> cryptoList)
    {
        using (SqlConnection connection = new SqlConnection(_connectionString))
        {
            await connection.OpenAsync();

            var deleteQuery = "DELETE FROM CryptoCurrencies";
            using (SqlCommand deleteCmd = new SqlCommand(deleteQuery, connection))
            {
                await deleteCmd.ExecuteNonQueryAsync();
            }

            foreach (var crypto in cryptoList)
            {
                var query = @"
                    IF EXISTS (SELECT 1 FROM CryptoCurrencies WHERE Id = @Id)
                    BEGIN
                        UPDATE CryptoCurrencies
                        SET Name = @Name, Symbol = @Symbol, CmcRank = @CmcRank,
                            CirculatingSupply = @CirculatingSupply, TotalSupply = @TotalSupply, 
                            MaxSupply = @MaxSupply, Price = @Price, MarketCap = @MarketCap, 
                            Volume24h = @Volume24h, PercentChange1h = @PercentChange1h, PercentChange24h = @PercentChange24h,
                            PercentChange7d = @PercentChange7d
                        WHERE Id = @Id
                    END
                    ELSE
                    BEGIN
                        INSERT INTO CryptoCurrencies (Id, Name, Symbol, CmcRank, CirculatingSupply, TotalSupply, MaxSupply, Price, MarketCap, Volume24h, PercentChange1h, PercentChange24h, PercentChange7d)
                        VALUES (@Id, @Name, @Symbol, @CmcRank, @CirculatingSupply, @TotalSupply, @MaxSupply, @Price, @MarketCap, @Volume24h, @PercentChange1h, @PercentChange24h, @PercentChange7d)
                    END";

                using (SqlCommand cmd = new SqlCommand(query, connection))
                {
                    cmd.Parameters.AddWithValue("@Id", crypto.Id);
                    cmd.Parameters.AddWithValue("@Name", crypto.Name);
                    cmd.Parameters.AddWithValue("@Symbol", crypto.Symbol);
                    cmd.Parameters.AddWithValue("@CmcRank", crypto.CmcRank);
                    cmd.Parameters.AddWithValue("@CirculatingSupply", crypto.CirculatingSupply);
                    cmd.Parameters.AddWithValue("@TotalSupply", crypto.TotalSupply);
                    cmd.Parameters.AddWithValue("@MaxSupply", crypto.MaxSupply);
                    cmd.Parameters.AddWithValue("@Price", crypto.Quotes[0].Price);
                    cmd.Parameters.AddWithValue("@MarketCap", crypto.Quotes[0].MarketCap);
                    cmd.Parameters.AddWithValue("@Volume24h", crypto.Quotes[0].Volume24h);
                    cmd.Parameters.AddWithValue("@PercentChange1h", crypto.Quotes[0].PercentChange1h);
                    cmd.Parameters.AddWithValue("@PercentChange24h", crypto.Quotes[0].PercentChange24h);
                    cmd.Parameters.AddWithValue("@PercentChange7d", crypto.Quotes[0].PercentChange7d);

                    cmd.Parameters.AddWithValue("@percentChange30d", crypto.Quotes[0].percentChange30d);

                    await cmd.ExecuteNonQueryAsync();
                }
            }
        }
    }
}
