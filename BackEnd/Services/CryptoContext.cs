using Microsoft.EntityFrameworkCore;

public class CryptoContext : DbContext
{
    public CryptoContext(DbContextOptions<CryptoContext> options) : base(options) { }

    public DbSet<CryptoCurrencyDbModel> CryptoCurrencies { get; set; } = null!;

}
