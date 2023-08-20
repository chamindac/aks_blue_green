using Azure.Identity;
using Lib01.Configs;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using Azure.Messaging.EventHubs.Producer;

var builder = WebApplication.CreateBuilder(args);

ConfigLoader.LoadConfiguration(builder.Configuration);
//builder.Configuration.AddJsonFile(Environment.GetEnvironmentVariable("CH_DEMO_CONFIG"));

//// Retrieve the connection string
//string appConfigConnection = builder.Configuration.GetValue<string>("AppConfig");
//string appConfigLabel = builder.Configuration.GetValue<string>("AppConfigLabel");
//string kvclientId = builder.Configuration.GetValue<string>("KVClientId");
//string kvclientSecret = builder.Configuration.GetValue<string>("KVClientSecret");
//string tenantId = builder.Configuration.GetValue<string>("AzureAdTenantId");

////Load configuration from Azure App Configuration
//builder.Configuration.AddAzureAppConfiguration(options =>
//                options
//                    .Connect(appConfigConnection)
//                    // Load configuration values with no label
//                    .Select(KeyFilter.Any, appConfigLabel)
//                    .ConfigureKeyVault(kv =>
//                    {
//                        kv.SetCredential(string.IsNullOrEmpty(kvclientId) || string.IsNullOrEmpty(kvclientSecret) || string.IsNullOrEmpty(tenantId)
//                            ? new DefaultAzureCredential() : new ClientSecretCredential(tenantId, kvclientId, kvclientSecret));
//                    })
//            );

// Bind configuration all configs to the Settings object
builder.Services.Configure<Settings>(builder.Configuration);

builder.Services.AddSingleton<EventHubProducerClient>(new EventHubProducerClient(builder.Configuration.GetValue<string>("EventHubPublisher1"), "neworder"));

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();


var app = builder.Build();

// Configure the HTTP request pipeline.
// if (app.Environment.IsDevelopment())
// {
    // app.UseSwagger(c =>
    // {
    //     c.RouteTemplate = "order/api/swagger/{documentname}/swagger.json";
    // });
    // app.UseSwaggerUI(c =>
    // {
    //     c.SwaggerEndpoint("/order/api/swagger/v1/swagger.json", "Order.API V1");
    //     c.RoutePrefix = "order/api/swagger";
    // });
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Order.API V1");
    });
// }

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
