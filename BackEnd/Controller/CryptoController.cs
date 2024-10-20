using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

[Route("api/[controller]")]
[ApiController]
public class CryptoController : ControllerBase
{
    private readonly CryptoContext _context;
    private readonly CryptoDataService _cryptoDataService;

    public CryptoController(CryptoContext context, CryptoDataService cryptoDataService)
    {
        _context = context;
        _cryptoDataService = cryptoDataService;
    }

    // GET: api/crypto
    [HttpGet]
    public async Task<ActionResult<IEnumerable<CryptoCurrencyDbModel>>> GetCryptoCurrencies(
        string? searchQuery = null, string? sortField = "rank", string? sortOrder = "asc")
    {
        var query = _context.CryptoCurrencies.AsQueryable();

        if (!string.IsNullOrEmpty(searchQuery))
        {
            query = query.Where(c => c.Name.Contains(searchQuery) || c.Symbol.Contains(searchQuery));
        }

        query = sortField?.ToLower() switch
        {
            "price" => sortOrder.ToLower() == "desc"
                ? query.OrderByDescending(c => c.Price)
                : query.OrderBy(c => c.Price),

            "percentchange24h" => sortOrder.ToLower() == "desc"
                ? query.OrderByDescending(c => c.PercentChange24h)
                : query.OrderBy(c => c.PercentChange24h),

            "marketcap" => sortOrder.ToLower() == "desc"
                ? query.OrderByDescending(c => c.MarketCap)
                : query.OrderBy(c => c.MarketCap),

            _ => sortOrder.ToLower() == "desc"
                ? query.OrderByDescending(c => c.CmcRank)
                : query.OrderBy(c => c.CmcRank),
        };

        return await query.ToListAsync();
    }



    // GET: api/crypto/update-data
    [HttpGet("update-data")]
    public async Task<IActionResult> UpdateData()
    {
        await _cryptoDataService.FetchAndUpdateData();
        return Ok("Data update triggered successfully.");
    }
}

