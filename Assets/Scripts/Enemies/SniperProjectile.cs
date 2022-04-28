using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SniperProjectile : MonoBehaviour
{
    [SerializeField]
    private float m_damage = 25f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnCollisionEnter(Collision collision)
    {
        print(collision.transform.tag);
        Debug.DrawRay(collision.contacts[0].point, collision.contacts[0].normal, Color.red, 5f);

        if (collision.transform.CompareTag("Player"))
        {
            var caca = collision.gameObject.GetComponent<CharacterHP>();
            caca.Damage(m_damage);
        }
        gameObject.SetActive(false);
    }
}
