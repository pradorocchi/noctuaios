//
//  NOOfertasEmpresaViewController.m
//  Noctua
//
//  Created by Alberto Javier Sánchez Peralta on 31/8/14.
//  Copyright (c) 2014 Alberto Javier Sánchez Peralta. All rights reserved.
//

#import "NOOfertasEmpresaViewController.h"

@interface NOOfertasEmpresaViewController ()

@end

@implementation NOOfertasEmpresaViewController

-(id) initWithEmpresa:(int)empresa
            Ubicacion:(CLLocationCoordinate2D)ubicacion
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.empresa   = empresa;
        self.ubicacion = ubicacion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Inicializamos el interfaz gráfico
    [self initUI];
    
    // Cargamos los datos
    [self CargarDatos];
}

////////////////////////////////////
// Inicializa el interfaz gráfico //
////////////////////////////////////
-(void) initUI
{
    // Establecemos el background
    [SPUtilidades setBackground:@"logobackground.png"
                       Posicion:45
                          Vista:self.view
                          Alpha:1.0f];
    
    // Establecemos el background de la vista
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Creamos la tabla donde aparecerán las ofertas
    self.tabla                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height - 50) style:UITableViewStylePlain];
    // Establecemos la fuente de datos
    self.tabla.dataSource      = self;
    self.tabla.delegate        = self;
    // Quitamos los separadores
    self.tabla.separatorColor  = [UIColor clearColor];
    self.tabla.backgroundColor = [UIColor clearColor];
    self.tabla.opaque          = NO;
    self.tabla.allowsSelection = YES;
    self.tabla.userInteractionEnabled = YES;
    self.tabla.showsVerticalScrollIndicator = NO;
    self.tabla.contentInset = UIEdgeInsetsMake(0, 0, 35, 0);
    // Añadimos la tabla a la vista
    [self.view addSubview:self.tabla];
    
    // Creamos el panel
    UIView * tipos = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 35, self.view.frame.size.width, 35)];
    tipos.backgroundColor = [RGB(97, 168, 221) colorWithAlphaComponent:0.9f];
    // Añadimos el panel a la vista
    [self.view addSubview:tipos];
    // Añadimos el texto
    [SPUtilidades setTextoEstatico:CGRectMake(10, 0, tipos.frame.size.width - 20, tipos.frame.size.height)
                             Texto:@"La empresa tiene más de una oferta disponible. Seleccione cualquier oferta para obtener información de la misma."
                            Fuente:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]
                         TextColor:[UIColor whiteColor]
                             Padre:tipos
                         Alignment:NSTextAlignmentCenter];
       
    // Creamos la barra de navegación
    [SPUtilidades crearBarraNavegacion:self Titulo:@"Ofertas" MenuIzquierdo:NO MenuDerecho:NO SelectorIzquierdo:@selector(volverAtras:)];
}

////////////////////////
// Cargamos los datos //
////////////////////////
-(void) CargarDatos
{
    // Parámetros JSON para la petición
    NSDictionary *params = @{
                             @"latitud"  : [NSNumber numberWithDouble: self.ubicacion.latitude],
                             @"longitud" : [NSNumber numberWithDouble: self.ubicacion.longitude],
                             @"empresa"  : [NSNumber numberWithInt: self.empresa]
                             };
    
    // Realizamos la petición POST
    [SPUtilidades procesarPeticionPOST: @"ofertasempresa"
                            Parametros: params
                          SuccessBlock: ^(id responseObject)
                                        {
                                            // Comprobamos si se ha producido un error
                                            if ([responseObject isKindOfClass:[NSArray class]])
                                            {
                                                // Creamos el array de datos
                                                self.listaofertas = [Oferta consumirLista:responseObject];
                             
                                                // Recargamos los datos
                                                [self.tabla reloadData];
                                            }
                                            else
                                            {
                                                // Se ha obtenido algún error
                                                [SPUtilidades mostrarError:@"Error" Mensaje:[responseObject objectForKey:@"Error"] Handler:^(SIAlertView *alertView) { }];
                                            }
                                        }
                          FailureBlock: ^(NSError *error)
                                        {
                                            // Se ha producido un error
                                            [SPUtilidades mostrarError:@"Error" Mensaje:@"No se ha podido obtener los datos de las consultas" Handler:^(SIAlertView *alertView) { }];
                                        }
     ];
}

////////////////////////
// Vuelve hacia atrás //
////////////////////////
-(void) volverAtras: (id) sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Delegado de UITableView
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.listaofertas count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 157.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NOOfertaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Oferta"];
    
    if (!cell)
    {
        cell = [[NOOfertaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:@"Oferta"];
    }
    
    // Obtenemos la fila de datos a mostrar
    Oferta* datos = [self.listaofertas objectAtIndex:indexPath.row];
   
    // Si no tenemos logo de empresa, ponemos una por defecto
    if (datos.logo == nil || [datos.logo isEqual:@""])
    {
        cell.logo.image = [UIImage imageNamed:@"logo.png"];
    }
    else
    {
        // Ahora indicamos que debemos cargar
        [cell.logo sd_setImageWithURL:[SPUtilidades urlImagenes:@"empresas" Imagen:[datos.logo stringByAppendingString:@".jpg"]]
                     placeholderImage:[UIImage imageNamed:@"loading.png"]
                              options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    }
    
    // Nos permitirá trocear la fecha
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:datos.inicio];
    
    // Establecemos el día de la oferta
    cell.dia.text = [NSString stringWithFormat:@"%02d", (int) [components day]];
    
    // Establecemos el nombre del mes
    cell.mes.text = [SPUtilidades nombreMes:(int) [components month] - 1];
    
    // Establecemos la hora
    cell.hora.text = [NSString stringWithFormat:@"%02d:%02d", (int) [components hour], (int) [components minute]];
    
    // Nombre de la oferta
    cell.nombre.text = datos.nombre;
    
    // Empresa de la oferta
    cell.empresa.text = datos.empresa;
    
    // Kilómetros a la empresa
    if ([datos.kilometros floatValue] < 1.0f) cell.kilometros.text = [[NSString stringWithFormat:@"%.02f", [datos.kilometros floatValue] * 100.0f] stringByAppendingString:@" mts."];
    else cell.kilometros.text = [[NSString stringWithFormat:@"%.02f", [datos.kilometros floatValue]] stringByAppendingString:@" kms."];
    
    // Desactivamos la selección
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Oferta* datos = [self.listaofertas objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:[[NOOfertaViewController alloc] initWithOferta:[datos.codigo intValue] Llevas:NO] animated:YES];
}

@end
