using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using Lib01.Configs;
using Lib01.Sql;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using System.Text;

namespace Invoice.API.Controllers;

[ApiController]
[Route("api")]
public class WeatherForecastController : ControllerBase
{
    private readonly Settings _settings;

    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;
    private readonly EventHubProducerClient _eventhubClient;

    public WeatherForecastController(ILogger<WeatherForecastController> logger, IOptionsSnapshot<Settings> options, EventHubProducerClient eventHubClient)
    {
        _logger = logger;
        _settings = options.Value;
        _eventhubClient = eventHubClient;
    }

    [HttpGet("forecast")]
    public IEnumerable<WeatherForecast> Get()
    {
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateTime.Now.AddDays(index),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray();
    }

    [HttpGet("forecastcount")]
    public int GetForecastCount()
    {
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateTime.Now.AddDays(index),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray().Count();
    }

    [HttpGet("health")]
    public IEnumerable<WeatherForecast> GetHealth()
    {
        // returns same forecast data as health api
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateTime.Now.AddDays(index),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray();
    }

    [HttpGet("newinvoice")]
    public async Task<string> NewOrder()
    {
        DateTime timeNow = TimeZoneInfo.ConvertTime(DateTime.Now, TimeZoneInfo.FindSystemTimeZoneById("CET")); // Linux CET Win Central Europe Standard Time
        string msgId = timeNow.ToString("dd-MM-yyyy-HH:mm:ss.fffffff-tt");

        await SqlCommanRunner.RunAsync(_settings.SqlDBConnection,
            $"INSERT INTO dbo.[Invoice] ([Number],[Status],[InitiatedByApp],[InitiatedByCluster],[IntiatedAt]) VALUES ('{msgId}','Initiated','Invoice.API','{_settings.AppConfigLabel}','{timeNow.ToString("MM/dd/yyyy HH:mm:ss.fff tt")}')");

        using EventDataBatch eventBatch = await _eventhubClient.CreateBatchAsync();
        eventBatch.TryAdd(new EventData()
        {
            MessageId = msgId,
            EventBody = new BinaryData(Encoding.UTF8.GetBytes($"New invoice {msgId}"))
        });
        await _eventhubClient.SendAsync(eventBatch);

        return $"New invoice initiated {msgId}";
    }
}
