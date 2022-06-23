using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Breakdown : MonoBehaviour
{
    [SerializeField]
    private GameObject m_golem;
    [SerializeField]
    private GameObject m_brokenGolem;
    [SerializeField]
    private GameObject m_explosion;
    [SerializeField]
    private GameObject m_smokeExplosion;

    [SerializeField]
    private float m_explosionMinForce = 5.0f;
    [SerializeField]
    private float m_explosionMaxForce = 100.0f;
    [SerializeField]
    private float m_explosionRadius = 10.0f;
    [SerializeField]
    private float m_scaleFactor = 1.0f;
    [SerializeField]
    private Material m_dissolve;

    private float m_dissolveAmount = 0.0f;

    private bool m_canDissolve = false;

    private GameObject m_fracturedGolem;

    public void SetActive()
    {
        m_golem.SetActive(true);
    }
    private void Start()
    {
        m_dissolveAmount = 0.0f;
    }

    private void Update()
    {
        if (m_canDissolve)
        {
            m_dissolveAmount += Time.deltaTime/4;
            m_dissolve.SetFloat("_Dissolve", m_dissolveAmount);
        }
    }

    public void Explode()
    {
        if(m_golem != null)
        {
            m_golem.SetActive(false);

            if(m_brokenGolem != null)
            {
                m_fracturedGolem = Instantiate(m_brokenGolem, m_golem.transform.position, m_golem.transform.rotation) as GameObject;

                foreach (Transform t in m_fracturedGolem.transform)
                {
                    var _rigidBody = t.GetComponent<Rigidbody>();

                    if(_rigidBody != null)
                    {
                        _rigidBody.AddExplosionForce(Random.Range(m_explosionMinForce, m_explosionMaxForce), m_golem.transform.position, m_explosionRadius);
                    }
                }
                m_canDissolve = true;

                Destroy(m_fracturedGolem, 3.5f);

                if(m_explosion != null && m_smokeExplosion != null)
                {
                    GameObject _explosionVFX = Instantiate(m_explosion, m_golem.transform.position, m_golem.transform.rotation) as GameObject;
                    Destroy(_explosionVFX, 7);

                    GameObject _smokeExplosionVFX = Instantiate(m_smokeExplosion, m_golem.transform.position, m_golem.transform.rotation) as GameObject;
                    Destroy(_smokeExplosionVFX, 2);
                }
            }
        }
        //Destroy(this.gameObject, 3.5f);
    }
}
