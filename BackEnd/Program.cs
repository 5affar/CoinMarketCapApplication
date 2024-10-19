using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        string connectionString = "Server=localhost;Database=CryptoData;Trusted_Connection=True;";

        builder.Services.AddControllers();

        builder.Services.AddDbContext<CryptoContext>(options =>
            options.UseSqlServer(connectionString));

        builder.Services.AddSingleton(new CryptoDataService(connectionString));

        var app = builder.Build();

        if (app.Environment.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }

        app.UseHttpsRedirection();
        app.UseAuthorization();

        app.MapControllers();

        app.Run();
    }
}
