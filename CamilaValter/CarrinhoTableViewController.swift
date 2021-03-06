//
//  CarrinhoTableViewController.swift
//  Minha Lista
//
//  Created by Valter Abranches on 06/10/17.
//  Copyright © 2017 Camila e Valter. All rights reserved.
//

import UIKit
import CoreData

class CarrinhoTableViewController: UITableViewController {
    
    //MARK: Propriedades
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    var fetchedProdutosController : NSFetchedResultsController<Produtos>!
    var produtos : [Produtos] = [Produtos]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 106
        tableView.rowHeight = UITableViewAutomaticDimension
        
        label.text = "Sua lista está vazia!"
        label.textAlignment = .center
        label.textColor = .black
        
        carregarProdutos()
        
    }

    
    func carregarProdutos(){
        let request : NSFetchRequest<Produtos> = Produtos.fetchRequest()
        let sort = NSSortDescriptor(key: "nome", ascending: true)
        request.sortDescriptors = [sort]
        
        fetchedProdutosController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedProdutosController.delegate = self
        
        do {
            try fetchedProdutosController.performFetch()
            self.produtos = fetchedProdutosController.fetchedObjects!
        } catch {}
        
    }
    

    //MARK: DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if produtos.count != 0 {
            tableView.backgroundView = nil
            print(produtos.count)
            return produtos.count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula", for: indexPath) as! CarrinhoTableViewCell
        let prod = fetchedProdutosController.object(at: indexPath)
        cell.lbNomeProduto.text = prod.nome
        cell.lbValorDolar.text = String(format: "U$ %.2f", prod.valor)
        
        let texto = "\(prod.estado?.nome ?? "-") (\(prod.estado?.imposto ?? 0.0) %)"
        
        cell.lbEstadoImposto.text = texto
        
        if prod.cartao {
            cell.lbCartaoIOF.text = "+ 6,38% (IOF)"
        } else {
            cell.lbCartaoIOF.text = "-"
        }
        
        DispatchQueue.global().async {
            if let imagem = prod.imagem as! Data? {
                let img = UIImage(data: imagem)
                DispatchQueue.main.async {
                    cell.ivPoster.image = img
                }
            } else {
                cell.ivPoster.image = #imageLiteral(resourceName: "bag")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let state = fetchedProdutosController.object(at: indexPath)
                context.delete(state)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    

}

extension CarrinhoTableViewController : NSFetchedResultsControllerDelegate {
    //MARK: NSFetch Delegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        produtos = fetchedProdutosController.fetchedObjects!
        tableView.reloadData()
    }
    
    
    
}

