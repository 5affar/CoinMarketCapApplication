using System.Net;
using System.Text.Json;

public class HttpService
{
    private readonly HttpClient _client;

    public HttpService()
    {
        HttpClientHandler handler = new HttpClientHandler 
        { 
            AutomaticDecompression = DecompressionMethods.All 
        };
        _client = new HttpClient(handler);
    }

    // GET method with automatic decompression
    public async Task<string> GetAsync(string uri)
    {
        using HttpResponseMessage response = await _client.GetAsync(uri);
        response.EnsureSuccessStatusCode(); 
        return await response.Content.ReadAsStringAsync();
    }

    // Method to deserialize JSON response into DataResponse class
    public async Task<DataResponse?> GetCryptoCurrencyDataAsync(string uri)
    {
        try
        {
            string jsonResponse = await GetAsync(uri);
            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };

            return JsonSerializer.Deserialize<DataResponse>(jsonResponse, options);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Deserialization error: {ex.Message}");
            return null;
        }
    }
}
