using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SniperProjectile : MonoBehaviour
{
    [SerializeField]
    private float m_damage = 25f;

    [SerializeField]
    private Rigidbody m_rigidBody;

    [SerializeField]
    private Transform m_rayPoint;

    [SerializeField]
    private float m_distanceHit;

    private void Start()
    {
        m_distanceHit = 5f;
    }

    //private void OnCollisionEnter(Collision collision)
    //{
    //    Debug.DrawRay(collision.contacts[0].point, collision.contacts[0].normal, Color.red, 5f);

    //    if (collision.transform.CompareTag("Player"))
    //    {
    //        var l_character = collision.gameObject.GetComponent<CharacterHP>();
    //        l_character.Damage(m_damage);
    //    }
    //    gameObject.SetActive(false);
    //}

    private void Update()
    {
        transform.rotation = Quaternion.LookRotation(m_rigidBody.velocity);

        Ray l_ray = new Ray(m_rayPoint.position, m_rayPoint.forward);

        if (Physics.Raycast(l_ray, out RaycastHit l_hit, m_distanceHit))
        {
            if (l_hit.transform.CompareTag(UtilsGyromitra.SearchForTag("Player"))) {
                l_hit.transform.GetComponent<CharacterHP>().Damage(m_damage);
            }
            gameObject.SetActive(false);
        }

    }

}
